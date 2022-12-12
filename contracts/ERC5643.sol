// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

//@dev interface for ERC5643
interface IERC5643 {
    event SubscriptionUpdate(uint256 indexed tokenId, uint64 expiration);
    function renewSubscription(uint256 tokenId, uint64 duration) external payable;
    function cancelSubscription(uint256 tokenId) external payable;
    function expiresAt(uint256 tokenId) external view returns(uint64);
    function isRenewable(uint256 tokenId) external view returns(bool);
}
contract Subscription is IERC5643, ERC721, ERC721Enumerable, ERC721URIStorage, Ownable, ERC721Burnable {

///////////////////////////////////////////////////
 ////// @dev state variables 
//////////////////////////////////////////////////
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    //@dev mapping
    mapping (uint256 => uint64) private expirations;
    mapping(uint256 => uint64) private renewable
    mapping(bytes => bool) private signatures;
    mapping (uint256 => uint256) public _price;


////////////////////////////////////
/////////////@dev constructor
//////////////////////////////
     constructor(string memory name, string memory symbol) ERC721(name, symbol){}

    //@dev function for support interface
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721ENUMERABLE)  returns (bool) {
        returns super.supportsInterface(interfaceId) || interfaceId == type(IERC5643).interfaceId;
    }
   

    //@dev mint subscription function 
    function mintSubscription(address to, uint64 duration, byte memory _signature, uint256 _value, uint64 _renewable, uint256 _timeStamp) public payable {
        bytes32 message = keccak256(abi.encodePacked(to, duration, _renewable, _value, _timeStamp, address(this)));
        require(msg.value == _value, "need the same value");
        require(!signatures[_signature], "error signature");
        require(_timeStamp + 5 minutes <= block.timestamp, "Error not time for signature");
        require(owner() == _recoverSigner(message, _signature), "Signature Error");
        signatures[_signature] = true;

        _tokenIds.increment();
        payable(owner()).transfer(msg.value); // transfer value to owner
        uint256 newTokenId = _tokenIds.current(); // get new token id 
        _mint(to, newTokenId); // mint token 
        _price[newTokenId] = msg.value / duration; // set price for token
        expirations[newTokenId] = uint64(block.timestamp) + _duration; // set expiration date for token
        renewable[newTokenId] = uint64(block.timestamp) + _renewable; // set renewable for token
        emit SubscriptionUpdate(newTokenId, expirations[newTokenId]);
        }
    
    // @dev renew subscription function
    function renewSubscription(uint256 tokenId, uint64 duration) public payable override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
        require(renewable[tokenId], "Subscription is not renewable");
        require(msg.value == (_price[tokenId] * duration), "Price is not correct");
        payable(owner()).transfer(_price[tokenId] * duration);
        uint64 currentExpiration = expirations[tokenId];
        uint64 newExpiration;
        if (currentExpiration == 0 || currentExpiration < uint64(block.timestamp)) {
        if(renewable[tokenId] > uint64(block.timestamp)){
            revert("Subscription is not renewable");
        }
        newExpiration = uint64(block.timestamp) + duration;
          
    }else {
        newExpiration = currentExpiration + duration;
    }
         expirations[tokenId] = newExpiration;
        emit SubscriptionUpdate(tokenId, expirations[tokenId]);
    }

    //@dev cancel subscription function
    function cancelSubscription(uint256 tokenId) public payable override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
        require(renewable[tokenId], "Subscription is not renewable");
        renewable[tokenId] = false;
        delete expirations[tokenId];
        delete price[tokenId];
        emit SubscriptionUpdate(tokenId, expirations[tokenId]);
    }
    event SubscriptionUpdate(tokenId, expirations[tokenId]);
    
////////////////////////////////////////////////////////////////////////////////
///////@dev function view 
////////////////////////////////////////////////////////////////////////////////
    //@dev function for view if subscription is renewable
    function isRenewable(uint256 tokenId) public view override returns(bool) {
        return renewable[tokenId];
    }

 //@dev function for look up expiration date
    function expiresAt(uint256 tokenId) public view override returns(uint64) {
        return expirations[tokenId];
    }

/////////////////////////////////////////////////////////////
///////@dev internal functions
/////////////////////////////////////////////////////////////


    function _recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = _splitSignature(sig);

        return ecrecover(message, v, r, s);
    }
   
}