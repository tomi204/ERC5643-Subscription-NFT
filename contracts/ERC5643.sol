// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.9;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";

interface IERC5643 {
    event SubscriptionUpdate(uint256 indexed tokenId, uint64 expiration);
    function renewSubscription(uint256 tokenId, uint64 duration) external payable;
    function cancelSubscription(uint256 tokenId) external payable;
    function expiresAt(uint256 tokenId) external view returns(uint64);
    function isRenewable(uint256 tokenId) external view returns(bool);
}
contract Subscription is IERC5643 {
    //@dev state variables 
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    //@dev mapping
    mapping (uint256 => uint64) private _expirations;
    mapping(uint256 => bool) private _renewable;
    mapping (uint256 => uint256) _price;

    //@dev function for support interface
    function supportsInterface(bytes4 interfaceId) public view virtual override  returns (bool) {
        returns super.supportsInterface(interfaceId) || interfaceId == type(IERC5643).interfaceId;
    }
    constructor() {
        
    }
}