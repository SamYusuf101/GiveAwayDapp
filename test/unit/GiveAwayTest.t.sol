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

    event GiveawayEntered(address indexed person);

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

    function testInitialGiveawayState() public {
        assert(
            giveAwayDapp.getGiveAwaystate() == GiveawayDapp.GiveAwayState.OPEN
        );
    }

    function testGiveAwayRevertIfYouDntPayEnough() public {
        vm.prank(PLAYER);

        vm.expectRevert(GiveawayDapp.GiveAway__NotEnoughEth.selector);
        giveAwayDapp.joinGiveAway();
    }

    function testGiveAwayrecordsPlayerswhenTheyEnter() public {
        vm.prank(PLAYER);
        vm.deal(PLAYER, 10 ether);

        giveAwayDapp.joinGiveAway{value: Starting_player_balance}();

        address peopleList = giveAwayDapp.getPlayers(0);

        assertEq(peopleList, PLAYER);
    }

    function testEnteringGiveAwayEmitEvent() public {
        vm.prank(PLAYER);
        vm.deal(PLAYER, 10 ether);

        vm.expectEmit(true, false, false, false, address(giveAwayDapp));

        emit GiveawayEntered(PLAYER);

        giveAwayDapp.joinGiveAway{value: entranceFee}();
    }

    function testDontAllowPeopleEnterGiveAwayWhileItsCalculating() public {
        vm.prank(PLAYER);
        vm.deal(PLAYER, 10 ether);
        giveAwayDapp.joinGiveAway{value: entranceFee}();
        vm.warp(block.timestamp + interval + 1);
        vm.roll(block.number + 1);
        giveAwayDapp.performUpkeep("");

        vm.expectRevert(GiveawayDapp.GIVEAWAY_notOPen.selector);
        vm.prank(PLAYER);
        vm.deal(PLAYER, 10 ether);

        giveAwayDapp.joinGiveAway{value: entranceFee}();
    }
}
