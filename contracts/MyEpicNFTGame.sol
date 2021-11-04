// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Helper we wrote to encode in Base64
import "./libraries/base64.sol";

import "hardhat/console.sol";

// Inheriting all characteristics from OpenZeppelin's ERC-721 standard
contract MyEpicGame is ERC721 {
  // Struct holding all characters' attributes
  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;        
    uint hp;
    uint maxHp;
    uint chakra;
    uint attackDamage;
  }

  struct BigBoss {
    string name;
    string imageURI;
    uint hp;
    uint maxHp;
    uint chakra;
    uint attackDamage;
  }

  // Initialize the Big Boss
  BigBoss public bigBoss;

  // NFTs unique identifier
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  
  // Array of all characters created
  CharacterAttributes[] defaultCharacters;

  // Mapping NFT's tokenId to NFT attributes
  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  // Mapping NFT owners to the NFTs tokenId.
  mapping(address => uint256) public nftHolders;

  // Events to be fired to the front-end app
  event AttackComplete(uint newBossHp, uint newPlayerHp);
  event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);

  // Data passed in to the contract when it's first created initializing the characters
  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterMaxHp,
    uint[] memory characterChakra,
    uint[] memory characterAttackDmg,
    string memory bossName,
    string memory bossImageURI,
    uint bossHp,
    uint bossChakra,
    uint bossAttackDamage
  )
  
  ERC721("Heroes", "HERO")
  
  {
    bigBoss = BigBoss({
      name: bossName,
      imageURI: bossImageURI,
      hp: bossHp,
      maxHp: bossHp,
      attackDamage: bossAttackDamage,
      chakra: bossChakra
    });

    console.log("Initialized boss %s w/ img %s and HP %s", bigBoss.name, bigBoss.imageURI, bigBoss.hp );

    // Function to loop through all characters created and add them to the contract's storage
    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterMaxHp[i],
        attackDamage: characterAttackDmg[i],
        chakra: characterChakra[i]
      }));

      CharacterAttributes memory c = defaultCharacters[i];
      console.log("Initialized %s w/ img %s and HP %s", c.name, c.imageURI, c.hp);
    }
    // Incrementing _tokenIds
    _tokenIds.increment();
  }

  // Function to generate tokenURI
  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

    string memory strHp = Strings.toString(charAttributes.hp);
    string memory strMaxHp = Strings.toString(charAttributes.maxHp);
    string memory strChakra = Strings.toString(charAttributes.chakra);
    string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

    string memory json = Base64.encode(
      bytes(
        string(
          abi.encodePacked(
            '{"name": "',
            charAttributes.name,
            ' -- NFT #: ',
            Strings.toString(_tokenId),
            '", "description": "This is an NFT that lets people play in the game Hokage Slayer!", "image": "',
            charAttributes.imageURI,
            '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value": ', strMaxHp,'}, { "trait_type": "Chakra Points", "value": ',
            strChakra,'}, { "trait_type": "Attack Damage", "value": ',
            strAttackDamage,'} ]}'
          )
        )
      )
    );

    string memory output = string(
      abi.encodePacked("data:application/json;base64,", json)
    );
    return output;
  }

  // Function for users to mint their NFTs
  function mintCharacterNFT(uint _characterIndex) external {
    // Get current tokenId (starts at 1 since we incremented in the constructor).
    uint256 newItemId = _tokenIds.current();

    // Assign the tokenId to the caller's wallet address.
    _safeMint(msg.sender, newItemId);

    // Map the tokenId => their character attributes.
    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      chakra: defaultCharacters[_characterIndex].chakra,      
      attackDamage: defaultCharacters[_characterIndex].attackDamage
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
    
    // Track which users owns the NFT
    nftHolders[msg.sender] = newItemId;

    // Incrementing _tokenIds
    _tokenIds.increment();

    // Event emitter
    emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
  }

  // Function to let players attack the boss
  function attackBoss() public {  
    uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
    CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
    console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
    console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);

    // Verify if the player has HP
    require (
      player.hp > 0,
      "Error: character must have HP to attack boss."
    );

    // Verify if the boss has HP
    require (
      bigBoss.hp > 0,
      "Error: boss must have HP to attack boss."
    );

    // Allow player to attack boss. If player kills the boss, set the boss' HP to 0.
    if (bigBoss.hp < player.attackDamage) {
      bigBoss.hp = 0;
    } else {
      bigBoss.hp = bigBoss.hp - player.attackDamage;
    }

    // Allow boss to attack player. If boss kills the player, set the player's HP to 0.
    if (player.hp < bigBoss.attackDamage) {
      player.hp = 0;
    } else {
      player.hp = player.hp - bigBoss.attackDamage;
    }

    console.log("Boss attacked player. New player hp: %s\n", player.hp);

    // Event emitter
    emit AttackComplete(bigBoss.hp, player.hp);
  }

  // Function to verify if user has already a hero NFt
  function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
    // Get the tokenId of the user's character NFT
    uint256 userNftTokenId = nftHolders[msg.sender];
    // If the user has a tokenId in the map, return their character.
    if (userNftTokenId > 0) {
      return nftHolderAttributes[userNftTokenId];
    }
    // Else, return an empty character.
    else {
      CharacterAttributes memory emptyStruct;
      return emptyStruct;
   }
  }

  // Function to retrieve all characters that can be minted
  function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
    return defaultCharacters;
  }

  // Function to return the boss for the fight
  function getBigBoss() public view returns (BigBoss memory) {
    return bigBoss;
  }
}