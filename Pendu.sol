
    // Jeu du pendu (1 et 1000) 
    // 2 Joueurs doivent deviner le nombre aléatoire choisi par le programme
    // Nombre d'essais : illimité

//SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

contract Pendu {

    uint public randomNumber;
    uint public attempts;
    uint nonce = 0 ;

    enum Number {
        GREATER,
        SMALLER,
        EQUAL
    }

    function intitializeGame() public {
        attempts = 0;
        nonce++;
        // This random number is deterministic, it can be calculated upfront by a miner.
        // To achieve true randomness, we can use oracles
        randomNumber = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))) % 1000 + 1; 


    }

    function guess(uint _guessedNumber) public returns (Number) {
        require(attempts < 10, "You already used your 10 attempts !");
        require(_guessedNumber > 0 && _guessedNumber <= 1000, "The number should be between 1 and 1000");

        attempts++;
        if(_guessedNumber > randomNumber ) return Number.GREATER;
        else if(_guessedNumber < randomNumber) return Number.SMALLER;
        else return Number.EQUAL;
    }
}

// Next step : make the game multiplayer
// Achieve true randomness through oracles
// Error management