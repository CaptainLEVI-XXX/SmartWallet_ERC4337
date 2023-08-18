// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import {SmartWallet} from "../src/SmartWallet.sol";
import {PayMaster} from "../src/PayMaster.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {WalletFactory} from "../src/WalletFactory.sol";
import "forge-std/Script.sol";
//import "forge-std/console.sol";

contract DeployMany is Script {
    SmartWallet public wallet;
    PayMaster public paymaster;
    EntryPoint public entryPoint;
    WalletFactory public factory;

    address public constant OWNER = 0x641BB2596D8c0b32471260712566BF933a2f1a8e;

    uint32 public constant UNSTAKE_DELAY = 10 seconds;
    uint112 PAYMASTER_DEPOSIT = 0.001 ether ;
    uint112 PAYMASTER_STAKE = 0.001 ether;

    //address constant CREATE2_FACTORY = 0x3bdcbd275741bd33D4A3e3469793065b528F1A93; //0xce0042B868300000d44A59004Da54A005ffdcf9f
    uint256 MIN_PAYMASTER_STAKE_AMOUNT = 1e6;
    uint32 MIN_PAYMASTER_STAKE_DURATION = 1 seconds;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        entryPoint = new EntryPoint();
       
        wallet = new SmartWallet(address(entryPoint), OWNER);
        
        paymaster = new PayMaster(address(entryPoint));
        
        factory = new WalletFactory();
     
        paymaster.addStake{value: PAYMASTER_STAKE}(UNSTAKE_DELAY);     //  Stake ETH on EntryPoint via Paymaster

        paymaster.deposit{value: PAYMASTER_DEPOSIT}();                //  Deposit ETH to pay for user transactions

        payable(address(wallet)).transfer(0.01 ether);                // Transfer some ETH to wallet

        vm.stopBroadcast();
    }
}
//source .env && forge script script/DeployMany.s.sol:DeployMany --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv