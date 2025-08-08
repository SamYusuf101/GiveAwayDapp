//SPDX-License-Identifier : MIT
pragma solidity 0.8.19;
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";

/**
 * @title A GiveawaDapp contract
 * @author Sam
 * @notice This contract is for creating a sample giveawayDapp
 * @dev Implements Chainlink VRFv2.5
 */
contract GiveawayDapp is VRFConsumerBaseV2Plus {
    /*ERROS*/
    error GiveAway__NotEnoughEth();
    uint256 private immutable i_entranceFee;
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;
    address payable[] public s_people;

    event GiveawayEntered(address indexed number);

    constructor(
        uint256 entranceFee,
        uint256 interval,
        address vrfCoordinator
    ) VRFConsumerBaseV2Plus(vrfCoordinator) {
        i_entranceFee = entranceFee;
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    function joinGiveAway() public payable {
        //  require(msg.value >= i_entranceFee,  NotEnoughEth());
        if (msg.value < i_entranceFee) {
            revert GiveAway__NotEnoughEth();
        }

        s_people.push(payable(msg.sender));

        emit GiveawayEntered(msg.sender);
    }

    function selectWinner() external {
        if ((block.timestamp - s_lastTimeStamp) < i_interval) {
            revert();
        }
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
    }

    function getEntranceFee() external view returns (uint256) {
        return i_entranceFee;
    }

    function fulfillRandomWords(
        uint256 requestId,
        uint256[] calldata randomWords
    ) internal override {}
}
