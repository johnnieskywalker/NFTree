pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import { BaseRoot } from "./BaseRoot.sol";
import { ITreeMinter } from "./ITreeMinter.sol";
import { CrossChainL1Minter } from "./CrossChainL1Minter.sol";

// TODO: afrter tests L1Root should not implement ITreeMinter 
contract L1Root is ERC721, BaseRoot, ITreeMinter, CrossChainL1Minter {

  //TODO: this values are trash
  uint8 public wasMintTreeCalled;
  address public ownerIncomingValue;

  //TODO: contract name mustbe L1Root
  constructor(address _l2Minter, address _l1messenger) ERC721("L1Root", "RT") CrossChainL1Minter(_l2Minter, _l1messenger) {}  

  //TODO for test purspose remove in final implementation
  function mintTree(address owner, string[][] memory newTree) external override(BaseRoot, ITreeMinter)  {
    wasMintTreeCalled = 1;   
    ownerIncomingValue = owner; 

    // TODO: add check that only Root address from L2 can send messages to this function (otherwise random people will mint whole trees)
    require(newTree.length > 1 && newTree[0].length > 1, "Tree for import must not be empty and must containt more than just a root");

    string memory rootHash = newTree[0][0];
    uint256 rootId = mintRoot(rootHash, owner);

    for(uint i = 0; i < newTree.length; i++) {
      for(uint j = 1; j < newTree[i].length; j++) {
        // newTree[0][0] is root and its alredy minted above
        string memory ancestorHash = newTree[i][0]; // frist element in each row is the parent node, and follwing elements in the row as his descendants (adjecency list graph representaion)
        uint256 ancestorNodeId = hashes[ancestorHash];
        mintNode(newTree[i][j], ancestorNodeId, rootId);
      }    
    }
  }

  string[][]  testArray;
  function testCrossChainMint(address l2Owner) public {
    testArray.push(["root", "node1", "node2"]);
    testArray.push(["node1", "node3"]);

    mintOnL2(l2Owner, testArray);
  }

  function crossChainMint(address l2Owner, uint256 rootId) public {
    string[][] memory exportTree = buildTreeForExportWithHash(rootId);
    mintOnL2(l2Owner, exportTree);
  }

  string public transferedStringData;
  function crossChainStringTransfer(address owner, string memory data) external override {
    require(0 > 1, "Not implemeted");  
  }

  function testStringTransfer(address l2Owner, string memory strData) public {
    sendString(l2Owner, strData);
  }

  string[][] public transferedStringArrayData;
  function crossChainStringArrayTransfer(address owner, string[][] memory data) external override {
    require(0 > 1, "Not implemeted");  
  }
  
  function testStringArrayTransfer(address l2Owner, string[][] memory strArrData) public {
    sendStringArray(l2Owner, strArrData);
  }

}