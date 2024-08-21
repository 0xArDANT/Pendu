// Jeu du pendu
// Intervalle de jeu : customisable
// 2 Joueurs doivent deviner le nombre aléatoire choisi par le programme
// Nombre d'essais : illimité

//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

contract Pendu {
    uint256 public game = 0;
    uint256 nonce = 0;

    mapping(address => uint256) public gamePlayers;
    mapping(uint256 => address) public gameOwner;
    mapping(uint256 => uint256[]) public gameIntervals;
    mapping(address => string) public playersNames;
    mapping(uint256 => uint256) public gameRandomNumber;

    modifier onlyLauncher() {
        require(
            gameOwner[gamePlayers[msg.sender]] == msg.sender,
            "You're not the launcher of this game"
        );
        _;
    }

    function intitializeGame(address _player2Addr) public {
        nonce++;
        game++;
        gameOwner[game] = msg.sender;
        gamePlayers[msg.sender] = game;
        gamePlayers[_player2Addr] = game;
    }

    function setIntervals(uint256 _lowerLimit, uint256 _greaterLimit)
        public
        onlyLauncher()
    {
        uint256 currentGame = gamePlayers[msg.sender];
        gameIntervals[currentGame].push(_lowerLimit);
        gameIntervals[currentGame].push(_greaterLimit);
    }

    function setPlayerName(string memory _playerName) public {
        playersNames[msg.sender] = _playerName;
    }

    function generateRandomNumber() public onlyLauncher {
        // This random number is deterministic, it can be calculated upfront by a miner.
        // To achieve true randomness, we can use oracles
        uint256 currentGame = gamePlayers[msg.sender];
        uint256 lower = gameIntervals[currentGame][0];
        uint256 greater = gameIntervals[currentGame][1];

        gameRandomNumber[currentGame] =
            (uint256(
                keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce))
            ) % lower) +
            1;
        if (gameRandomNumber[currentGame] < greater)
            gameRandomNumber[currentGame] += greater - lower;
    }

    function guessTheCorrectNumber(uint256 _guessedNumber)
        public
        view
        returns (string memory)
    {
        uint256 currentGame = gamePlayers[msg.sender];
        require(
            _guessedNumber > gameIntervals[currentGame][0] &&
                _guessedNumber <= gameIntervals[currentGame][1],
            "The number is out of limits"
        );

        if (_guessedNumber > gameRandomNumber[currentGame])
            return "Your number is too great";
        else if (_guessedNumber < gameRandomNumber[currentGame])
            return "Your number is too small";
        else {
            // recommencer la partie
            return string.concat("The winner is ", playersNames[msg.sender]);
        }
    }
}

// Next steps
// Permettre le jeu à 2 en créant une partie qui prend en compte l'addresse des joueurs OK
// Permettre aux joueurs de choisir l'intervalle de jeu OK
// permettre aux joeurs de recommencer automatiquement la partie, en cas de victoire.
// Rendre le nombre réellement aléatoire grâce aux oracles
// Gestion d'erreurs
// Permettre aux joeurs de mettre des tokens en jeu qui seront sauvegardés par le smart contract et transférés au gagnant.
// Le gagnant d'une manche commence la prochaine.
