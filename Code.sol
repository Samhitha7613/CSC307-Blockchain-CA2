// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BettingGame {
    address public owner;
    uint256 public betAmount;
    address[] public participants;
    mapping(address => bool) public hasBet;

    event BetPlaced(address indexed participant);
    event WinnerDeclared(address indexed winner, uint256 amount);

    constructor(uint256 _betAmount) {
        owner = msg.sender;
        betAmount = _betAmount;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier notBetYet() {
        require(!hasBet[msg.sender], "You have already placed a bet");
        _;
    }

    function placeBet() public payable notBetYet {
        require(msg.value == betAmount, "Incorrect bet amount");

        hasBet[msg.sender] = true;
        participants.push(msg.sender);

        emit BetPlaced(msg.sender);
    }

    function selectWinner() public onlyOwner {
        require(participants.length > 0, "No participants");

        uint256 randomIndex = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    participants
                )
            )
        ) % participants.length;

        address winner = participants[randomIndex];
        uint256 prize = address(this).balance;

        (bool success, ) = winner.call{value: prize}("");
        require(success, "Transfer failed");

        emit WinnerDeclared(winner, prize);

        // Reset the game state
        for (uint256 i = 0; i < participants.length; i++) {
            hasBet[participants[i]] = false;
        }
        delete participants;
    }
}
