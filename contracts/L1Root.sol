pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";

import { BaseRoot } from "./BaseRoot.sol";
import { IL1Minter } from "./IL1Minter.sol";

contract L1Root is BaseRoot, IL1Minter {

  uint8 public wasMintTreeCalled;
  address public ownerIncomingValue;

  constructor() BaseRoot() {}

  function mintTree(address owner, string[][] memory tree) external override {
    wasMintTreeCalled = 1;   
    ownerIncomingValue = owner; 

    // TODO: add check that only Root address from L2 can send messages to this function (otherwise random people will mint whole trees)
    require(tree.length > 1 && tree[0].length > 1, "Tree for import must not be empty and must containt more than just a root");

    string memory rootHash = tree[0][0];
    uint256 rootId = mintRoot(rootHash, owner);

    for(uint i = 0; i < tree.length; i++) {
      for(uint j = 0; j < tree[i].length; j++) {
        if(i != 0 && j !=0) {               // tree[0][0] is root and its alredy minted above
          string memory ancestorHash = tree[i][0]; // frist element in each row is the parent node, and follwing elemesnts in the row as his descendants (adjecency list graph representaion)
          uint256 ancestorNodeId = hashes[ancestorHash];
          // mintNode(tree[i][j], ancestorNodeId, rootId);
          // mintNode(tree[i][j], ancestorNodeId);
        }    
      }    
    }
  }

  function mintRoot(string memory hash, address owner) public returns (uint256) {
    return mintRootInternal(hash, owner);  
  }

  function mintRoot(string calldata hash) public returns (uint256) {
     return mintRootInternal(hash);
  }

  function mintNode(string memory hash, uint256 ancestorNodeId) public returns(uint256) {
    return super.mintNodeInternal(hash, ancestorNodeId);
  }

  string tmpShit;

  function mintMyHead(string memory testHash, uint256 aNId) public returns(uint256) {
    // console.log(testHash);
    // console.log(aNId);
    // console.log(rootId);

    tmpShit = testHash;
    // return aNId + rootId;
    return aNId + 1;
  }

}