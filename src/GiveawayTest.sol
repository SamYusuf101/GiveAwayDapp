//SPDX-License-Identifier : MIT
pragma solidity 0.8.19;


contract GiveawayTest {

    event giveAwayEntered(address indexed person);;
 address payable [] public s_people;
 uint256 private i_entranceFee;

 constructor(uint256 entranceFee) {
    i_entranceFee = entranceFee;

 }


    function enterGiveAway () public {
        require (msg.value > i_entranceFee, "not enough sent");
        s_people.push(payable(msg.sender));
        emit giveAwayEntered;

    }

    function selectWinner () public {

    }
}