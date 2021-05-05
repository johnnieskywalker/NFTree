pragma solidity >=0.6.0 <0.8.0;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Architect is ERC721 {

  string public network;
  address public owner;

  constructor(string memory networkName) ERC721("Architect", "ARCH") {
    owner = msg.sender;
    network = networkName;
  }

  function mintRoot() public {

  }



}




