<div style="text-align: center;">
    <img src="hero.png" alt="Banner" ">
</div>

## Problem Statement

Design a **Solidity smart contract** to implement a **simple betting mechanism** where participants can bet a **fixed amount**. Each participant can bet only once per round. At the end of the round, a winner is chosen randomly, and the contract balance is transferred to the winner. The mechanism should ensure fairness, security, and ease of participation.

## Approach and Implementation

The contract facilitates a betting game with the following steps:

1. **Initialization:** The contract is deployed with a specified betting amount. The deployer becomes the contract owner and has administrative rights.
2. **Placing Bets:** Participants bet a fixed amount by calling a specific function. Only one bet per address is allowed during a round.
3. **Winner Selection:** The winner is chosen randomly using a pseudo-random mechanism. Only the contract owner can trigger winner selection.
4. **Prize Distribution:** The entire balance of the contract is transferred to the selected winner. All participant data is reset after the winner is declared to prepare for the next round.
5. **Security Measures:** Prevent reentrancy attacks and ensure the integrity of funds. Restrict sensitive functions to authorized users.

## Module Wise Explanation

### Basic Implementation

#### 1.Initialization

The core state variables manage game data:

- **`owner`:** The contract deployer with special privileges (e.g., starting/ending the game).
- **`betAmount`:** The fixed amount required to place a bet.
- **`participants`:** An array storing addresses of all participants.
- **`hasParticipated`:** A mapping to ensure each address can only participate once.


##### Key concepts
1. **Owner Assignment:** The deployer of the contract is assigned as the owner and has exclusive rights to manage critical functionalities like selecting a winner.
2. **Fixed Bet Amount:** The bet amount is set at the time of contract deployment and cannot be changed.
3. **State Variables:** These variables are used to store critical data, such as participant addresses, their betting status, and contract balances.

```solidity
pragma solidity ^0.8.0;

contract BettingGame {
    address public owner;
    uint256 public betAmount;
    address[] public participants;
    mapping(address => bool) public hasBet;

    // Events for logging activities
    event BetPlaced(address indexed participant);
    event WinnerDeclared(address indexed winner, uint256 amount);

    // Constructor to initialize the owner and bet amount
    constructor(uint256 _betAmount) {
        owner = msg.sender;
        betAmount = _betAmount;
    }
}
```
#### Testing

```solidity
function testInitialization() public {
    uint256 expectedBetAmount = 1 ether;
    Assert.equal(bettingGame.betAmount(), expectedBetAmount, "Bet amount initialization failed");
    Assert.equal(bettingGame.owner(), msg.sender, "Owner initialization failed");
}
```

### 2. Placing Bets / Betting Mechanism
The placeBet function allows participants to place their bets. It performs several checks to ensure fairness:

1. **Amount Verification:**
- Participants must send exactly the `betAmount`.
- Any mismatch results in a revert, ensuring consistency.
  
2. **Single Bet Restriction:**
- An address can only place one bet per round.
- This is enforced using a mapping (`hasBet`) that tracks participants.
  
3. **Event Emission:**
Each successful bet triggers a `BetPlaced` event, allowing for tracking and transparency.

```solidity
function placeBet() public payable {
    require(msg.value == betAmount, "Incorrect bet amount");
    require(!hasBet[msg.sender], "You have already placed a bet");

    hasBet[msg.sender] = true;
    participants.push(msg.sender);

    emit BetPlaced(msg.sender);
}
```
#### Testing
- Ensure participants can place bets successfully.
- Test that participants cannot bet more than once per round.
- Verify that incorrect bet amounts are rejected.

```solidity
function testPlaceBet() public {
    address participant = address(0x123);
    uint256 initialBalance = address(this).balance;

    // Simulate bet
    participant.call{value: betAmount}("");

    // Assertions
    Assert.equal(address(this).balance, initialBalance + betAmount, "Bet not added to contract balance");
    Assert.isTrue(hasBet[participant], "Bet tracking failed");
}
```

### 3. Winner Selection
The `selectWinner` function determines the winner at the end of a betting round. It performs the following steps:

1. **Access Control:**
- Only the contract owner can call this function.
- The `onlyOwner` modifier ensures restricted access.
  
2. **Random Winner Selection:**
- A random index is generated using a pseudo-random function.
- The randomness is based on the current block timestamp, block difficulty, and participants' data.
  
3. **Prize Distribution:**
- The contract transfers its entire balance to the winner.
- This ensures the full prize pool is distributed.

4. **State Reset:**
Participants and their betting status are cleared for the next round.

```solidity
function selectWinner() public onlyOwner {
    require(participants.length > 0, "No participants");

    uint256 randomIndex = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, participants))) % participants.length;
    address winner = participants[randomIndex];

    uint256 prize = address(this).balance;
    payable(winner).transfer(prize);

    emit WinnerDeclared(winner, prize);

    // Reset state
    for (uint256 i = 0; i < participants.length; i++) {
        hasBet[participants[i]] = false;
    }
    delete participants;
}
```

#### Testing
- Verify that only the owner can select the winner.
- Ensure the winner receives the entire contract balance.
- Confirm that the state resets correctly after the winner is declared.

```solidity

function testSelectWinner() public {
    address participant1 = address(0x123);
    address participant2 = address(0x456);

    participant1.call{value: betAmount}("");
    participant2.call{value: betAmount}("");

    uint256 initialBalance = address(this).balance;

    // Select winner
    selectWinner();

    // Assertions
    Assert.equal(address(this).balance, 0, "Contract balance not emptied");
    // Mock checks to ensure winner's balance received prize
}
```
4. **Security Measures:**
The contract employs the following security mechanisms:

1. **Reentrancy Protection:**
Using Solidity's `transfer` function prevents reentrancy attacks.

2. **Access Restrictions:**
Only the owner can manage critical operations like selecting a winner.

3. **Fairness Assurance:**
Participants can only place one bet per round, ensuring fair play.

#### modifiers

```solidity
modifier onlyOwner() {
    require(msg.sender == owner, "Only the owner can call this function");
    _;
}
```

## Conclusion
The betting contract provides a simple, secure, and transparent way for participants to bet and win. It ensures:

1. Fairness through fixed bet amounts and single-bet restrictions.
2. Random winner selection for unpredictability.
3. Complete prize distribution to the winner.

### Future Enhancements:

1. **True Randomness:** Integrate Chainlink VRF for tamper-proof randomness.
2. **Dynamic Bet Amounts:** Allow participants to bet varying amounts with proportional payouts.
3. **Concurrent Rounds:** Implement functionality for multiple betting rounds running simultaneously.
4. **Pause Mechanism:** Add the ability to pause or resume betting for maintenance or emergencies.











