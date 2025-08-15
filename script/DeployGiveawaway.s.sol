//SPDX-License-Identifier : MIT
pragma solidity 0.8.19;
import {GiveawayDapp} from "../src/GiveawayDapp.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployGiveAway is Script {
    function run() public {}

    function deployContract() public returns (GiveawayDapp, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        vm.startBroadcast();
        GiveawayDapp giveawayDapp = new GiveawayDapp(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callBackGasLimit
        );

        vm.startBroadcast();
        return (giveawayDapp, helperConfig);
    }
}
