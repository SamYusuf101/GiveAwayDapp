//SPDX-License-Identifier : MIT
pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A GiveawaDapp contract
 * @author Sam
 * @notice This contract is for creating a sample giveawayDapp
 * @dev Implements Chainlink VRFv2.5
 */
contract GiveawayDapp is VRFConsumerBaseV2Plus {
    enum GiveAwayState {
        OPEN,
        CALCULATING
    }

    event winnerPicked(address indexed recentWinner);

    /*ERROS*/
    error GiveAway__NotEnoughEth();
    error TRANSFER__FAILED();
    error GIVEAWAY_notOPen();

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint16 private constant NUM_WORDS = 1;
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint32 private immutable i_callBackGasLimit;
    address private s_recentWinner;
    uint256 private s_lastTimeStamp;
    uint256 private immutable i_subscriptionId;
    address payable[] public s_people;
    GiveAwayState private s_giveAwayState;

    event GiveawayEntered(address indexed person);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callBackGasLimit
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callBackGasLimit = callBackGasLimit;
        s_lastTimeStamp = block.timestamp;
        s_giveAwayState = GiveAwayState.OPEN;
    }

    function joinGiveAway() public payable {
        //  require(msg.value >= i_entranceFee,  NotEnoughEth());
        if (msg.value < i_entranceFee) {
            revert GiveAway__NotEnoughEth();
        }

        if (s_giveAwayState != GiveAwayState.OPEN) {
            revert GIVEAWAY_notOPen();
        }

        s_people.push(payable(msg.sender));

        emit GiveawayEntered(msg.sender);
    }

    /**
     * @dev function that the chainlin nodes will call to see if a winner
     * is ready to be picked.
     */

    function checkUpkeep(
        bytes memory/* checkData */
    ) public view returns (bool upKeepNeeded, bytes memory /*performData*/) {
        bool timeHasPassed =  ((block.timestamp - s_lastTimeStamp) >= i_interval) ;
        bool isOpen = s_giveAwayState == GiveAwayState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPeople = s_people.length > 0;
        upKeepNeeded = timeHasPassed && isOpen && hasBalance && hasPeople;
        return (upKeepNeeded, ""); 
        
    }

   function performUpkeep(bytes calldata /* performData */)  external {
    (bool upkeepNeeded, ) = checkUpkeep("");
        if (!upkeepNeeded) {
            revert();
        }

        s_giveAwayState = GiveAwayState.CALCULATING;
        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callBackGasLimit,
                numWords: NUM_WORDS,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {
        uint256 indexOfwinner = randomWords[0] % s_people.length;
        address payable recentWinner = s_people[indexOfwinner];
        s_recentWinner = recentWinner;
        s_giveAwayState = GiveAwayState.OPEN;
        s_people = new address payable[](0);
        s_lastTimeStamp = block.timestamp;
        emit winnerPicked(recentWinner);
        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        require(success, "Transfer failed");
        //another way to revert!
        // if(!success) {
        //     revert TRSANSFER__FAILED();
        // }
    }
}
