// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {SubscriptionsNFT} from "../src/ERC5643.sol";

contract subScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        new SubscriptionsNFT("sub", "Ala");
    }
}
