pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import { BaseRoot } from "./BaseRoot.sol";
import { ITreeMinter } from "./ITreeMinter.sol";
import { CrossChainL2Minter } from "./CrossChainL2Minter.sol";

contract L2Root is ERC721, BaseRoot, ITreeMinter, CrossChainL2Minter {

  string[][]  testArray; 
  //TODO: this values are trash
  uint8 public wasMintTreeCalled;
  address public ownerIncomingValue;


  // TODO: remove _l1Minter from constructor and move to init method that can be called after L1 and L2 root contracts are ready and can be passed to each other
  constructor(address _l1Minter, address _l2messenger) ERC721("L2Root", "RT") CrossChainL2Minter(_l1Minter, _l2messenger) {}  

  function testCrossChainMint(address l1Owner) public {
    testArray.push(["root", "node1", "node2"]);
    testArray.push(["node1", "node3"]);

    mintOnL1(l1Owner, testArray);
  }

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

  function crossChainMint(address l1Owner, uint256 rootId) public {
    string[][] memory exportTree = buildTreeForExportWithHash(rootId);
    mintOnL1(l1Owner, exportTree);
  }

  string public transferredStringData;
  function crossChainStringTransfer(address owner, string memory data) external override {
    // require(0 > 1, "Not implemeted");  
    transferredStringData = data;
  }

  function getTransferredStringData() public view returns(string memory) {
    return transferredStringData;
  }

  string[][] public transferedStringArrayData;
  function crossChainStringArrayTransfer(address owner, string[][] memory data) external override {
    transferedStringArrayData = data;
  } 

  function getTransferredStringArrayData() public view returns(string[][] memory) {
    return transferedStringArrayData;
  }

}