// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.9;
interface IERC5643 {
    event SubscriptionUpdate(uint256 indexed tokenId, uint64 expiration);
    function renewSubscription(uint256 tokenId, uint64 duration) external payable;
    function cancelSubscription(uint256 tokenId) external payable;
    function expiresAt(uint256 tokenId) external view returns(uint64);
    function isRenewable(uint256 tokenId) external view returns(bool);
}
contract Subscription is IERC5643 {
    constructor() {
        
    }
}