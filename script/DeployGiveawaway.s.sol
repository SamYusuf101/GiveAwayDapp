//SPDX-License-Identifier : MIT
pragma solidity 0.8.19;
import {GiveawayDapp} from "../src/GiveawayDapp.sol";
import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription} from "./Interactions.s.sol";

contract DeployGiveAway is Script {
    function run() public {}

    function deployContract() public returns (GiveawayDapp, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        if(config.subscriptionId == 0 ) {
            CreateSubscription createSubscription = new CreateSubscription();
            (config.subscriptionId, config.vrfCoordinator) = createSubscription.createSubscription(config.vrfCoordinator);
        }

        vm.startBroadcast();
        GiveawayDapp giveawayDapp = new GiveawayDapp(
            config.entranceFee,
            config.interval,
            config.vrfCoordinator,
            config.gasLane,
            config.subscriptionId,
            config.callBackGasLimit
        );

        vm.stopBroadcast();
        return (giveawayDapp, helperConfig);
    }
}
