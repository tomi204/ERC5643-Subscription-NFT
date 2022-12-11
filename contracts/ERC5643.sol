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
    //@dev state variables 
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    //@dev mapping
    mapping (uint256 => uint64) private expirations;
    mapping(uint256 => uint64) private renewable
    mapping(bytes => bool) private signatures;
    mapping (uint256 => uint256) _price;

// @dev constructor
     constructor(string memory name, string memory symbol) ERC721(name, symbol) {

        
    }
    //@dev function for support interface
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721ENUMERABLE)  returns (bool) {
        returns super.supportsInterface(interfaceId) || interfaceId == type(IERC5643).interfaceId;
    }
    //@dev function for look up expiration date
    function expiresAt(uint256 tokenId) public view override returns(uint64) {
        return expirations[tokenId];
    }

    //@dev mint subscription function 
    function mintSubscription(address to, uint64 duration) public onlyOwner returns(uint256) {
        require(msg.value >= 0.5 ether);
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(to, newTokenId);
      
        expirations[newTokenId] = uint64(block.timestamp) + duration;
        renewable[newTokenId] = true;
        return newTokenId;
    }
    
    //@dev renew subscription function
    function renewSubscription(uint256 tokenId, uint64 duration) public payable override {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
        require(renewable[tokenId], "Subscription is not renewable");
        require(msg.value == _price[tokenId], "Price is not correct");
        expirations[tokenId] = uint64(block.timestamp) + duration;
        renewable[tokenId] = true;
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
   
}