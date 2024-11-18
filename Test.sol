// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "remix_tests.sol"; // Remix testing library
import "./BettingGame.sol"; // Import the BettingGame contract

contract TestBettingGame {
    BettingGame public bettingGame;
    address owner;
    address participant1;
    address participant2;
    uint256 betAmount;

    function beforeEach() public {
        // Setup the environment for each test
        owner = address(this);
        participant1 = address(0x123);
        participant2 = address(0x456);
        betAmount = 1 ether; // 1 ETH as the bet amount
        bettingGame = new BettingGame(betAmount); // Deploy a new instance of BettingGame
    }

    function testInitialOwner() public {
        // Check if the owner is set correctly
        Assert.equal(bettingGame.owner(), owner, "Owner should be the contract deployer");
    }

    function testPlaceBet() public {
        // Test if a participant can place a bet
        (bool success, ) = address(bettingGame).call{value: betAmount}(abi.encodeWithSignature("placeBet()"));
        Assert.ok(success, "Bet placement should succeed");
    }

    function testPlaceBetMultiple() public {
        // Test placing multiple bets
        bettingGame.placeBet{value: betAmount}();
        bettingGame.placeBet{value: betAmount}();
        
        // Check the participants count
        uint256 participantCount = bettingGame.participants.length;
        Assert.equal(participantCount, 2, "There should be 2 participants");
    }

    function testPlaceBetRevertIfAlreadyBet() public {
        // Test if a participant cannot place multiple bets
        bettingGame.placeBet{value: betAmount}();
        (bool success, ) = address(bettingGame).call{value: betAmount}(abi.encodeWithSignature("placeBet()"));
        Assert.equal(success, false, "Bet placement should fail if already placed a bet");
    }

    function testSelectWinner() public {
        // Test selecting a winner
        bettingGame.placeBet{value: betAmount}();
        bettingGame.placeBet{value: betAmount}();

        uint256 initialBalance = address(participant1).balance;
        bettingGame.selectWinner();

        // Check if the winner received the prize (i.e., 2 ETH in this case)
        uint256 finalBalance = address(participant1).balance;
        Assert.equal(finalBalance, initialBalance + betAmount * 2, "Winner should receive the correct prize");
    }

    function testResetGameAfterWinner() public {
        // Test that the game is reset after selecting a winner
        bettingGame.placeBet{value: betAmount}();
        bettingGame.placeBet{value: betAmount}();

        bettingGame.selectWinner();
        
        uint256 participantCount = bettingGame.participants.length;
        Assert.equal(participantCount, 0, "Participants should be reset after selecting a winner");
    }
}
