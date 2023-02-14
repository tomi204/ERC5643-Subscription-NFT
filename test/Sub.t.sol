// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {SubscriptionsNFT} from "../src/ERC5643.sol";

contract SubrTest is Test {
    SubscriptionsNFT sub;
    address user = address(0x01);

    function setUp() public {
        sub = new SubscriptionsNFT("SubscriptionsNFT", "SUB");
    }

    function test() public {}
}
