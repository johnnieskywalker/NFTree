pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import { BaseRoot } from "./BaseRoot.sol";
import { CrossChainL2Minter } from "./CrossChainL2Minter.sol";

contract L2Root is ERC721, BaseRoot, CrossChainL2Minter {

  string[][]  testArray; 

  constructor(address _l1Minter, address _l2messenger) ERC721("Root", "RT") CrossChainL2Minter(_l1Minter, _l2messenger) {}  

  function testCrossChainMint(address l1Owner) public {
    testArray.push(["root", "node1", "node2"]);
    testArray.push(["node1", "node3"]);

    mintOnL1(l1Owner, testArray);
  }

}