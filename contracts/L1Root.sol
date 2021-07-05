pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import { BaseRoot } from "./BaseRoot.sol";
import { IL1Minter } from "./IL1Minter.sol";

contract L1Root is ERC721, BaseRoot, IL1Minter {

  //TODO: this values are trash
  uint8 public wasMintTreeCalled;
  address public ownerIncomingValue;

  constructor() ERC721("Root", "RT") {}  

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
          mintNode(tree[i][j], ancestorNodeId);
        }    
      }    
    }
  }

}