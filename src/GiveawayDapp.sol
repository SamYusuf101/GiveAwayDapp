//SPDX-License-Identifier : MIT
pragma solidity 0.8.19;



/**
 * @title A GiveawaDapp contract
 * @author Sam
 * @notice This contract is for creating a sample giveawayDapp
 * @dev Implements Chainlink VRFv2.5
 */
contract GiveawayDapp {
    uint256 private immutable i_entranceFee;
    constructor(uint256 entranceFee){
    i_entranceFee = entranceFee;
    }
    function joinGiveAway () public payable{

    }

    function selectWinner () public {

    }

    function getEntranceFee () public view returns (uint256) {
        return i_entranceFee;
    }

}