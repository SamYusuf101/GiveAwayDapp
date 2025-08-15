//SPDX-License-Identifier : MIT
pragma solidity 0.8.19;
import {Test} from "forge-std/Test.sol";
import {DeployGiveAway} from "../../script/DeployGiveawaway.s.sol";
import {GiveawayDapp} from "../../src/GiveawayDapp.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract GiveAwaytest is Test {
    address public PLAYER = makeAddr("player");
    uint256 public constant Starting_player_balance = 10 ether;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint256 subscriptionId;
    uint32 callBackGasLimit;

    GiveawayDapp public giveAwayDapp;
    HelperConfig public helperConfig;

    function setUp() public {
        DeployGiveAway deployGiveAway = new DeployGiveAway();
        (giveAwayDapp, helperConfig) = deployGiveAway.deployContract();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        subscriptionId = config.subscriptionId;
        callBackGasLimit = config.callBackGasLimit;
    }

    function testInitialGiveawayState() public view{
        assert(giveAwayDapp.getGiveAwaystate() == GiveawayDapp.GiveAwayState.OPEN);
    }
}
