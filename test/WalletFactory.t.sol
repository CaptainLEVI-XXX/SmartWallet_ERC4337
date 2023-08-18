// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {WalletFactory} from "../src/WalletFactory.sol";
import {SmartWallet} from "../src/SmartWallet.sol";

contract WalletFactoryTest is Test{
    
    WalletFactory walletFactory;
    SmartWallet smartWallet;
    
    address public entry_point = address(0x1);
    address public owner = address(0x2);
    uint256 public salt = 0x3;

    function setUp() public {
        walletFactory = new WalletFactory();
    }

    function testDeploymentSmartWallet() public {
        smartWallet = walletFactory.deployWallet(entry_point, owner, salt);
        address computeCounterFactualAddress = walletFactory.computeAddress(entry_point, owner, salt);
       
        assertEq(address(smartWallet),computeCounterFactualAddress);
        assertEq(address(smartWallet.owner()),owner);
        assertEq(address(smartWallet.entryPoint()),entry_point);
    
    }
}

// forge test --match-path test/WalletFactory.t.sol