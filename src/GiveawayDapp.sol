//SPDX-License-Identifier : MIT
pragma solidity 0.8.19;

/**
 * @title A GiveawaDapp contract
 * @author Sam
 * @notice This contract is for creating a sample giveawayDapp
 * @dev Implements Chainlink VRFv2.5
 */
contract GiveawayDapp {
    /*ERROS*/
    error GiveAway__NotEnoughEth();
    uint256 private immutable i_entranceFee;
    address payable[] public s_people;

    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    function joinGiveAway() public payable {
        //  require(msg.value >= i_entranceFee,  NotEnoughEth());
        if (msg.value < i_entranceFee) {
            revert GiveAway__NotEnoughEth();
        }

        s_people.push(payable(msg.sender));
    }

    function selectWinner() public {}

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }
}
