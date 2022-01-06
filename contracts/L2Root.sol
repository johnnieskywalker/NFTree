pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

import { BaseRoot } from "./BaseRoot.sol";
import { ITreeMinter } from "./ITreeMinter.sol";
import { CrossChainL2Minter } from "./CrossChainL2Minter.sol";

contract L2Root is ERC721, BaseRoot, ITreeMinter, CrossChainL2Minter  {

  string[][]  testArray; 
  //TODO: this values are trash
  // uint8 public wasMintTreeCalled;
  uint256 public wasMintTreeCalled;
  address public ownerIncomingValue;


  // TODO: remove _l1Minter from constructor and move to init method that can be called after L1 and L2 root contracts are ready and can be passed to each other
  // constructor(address _l1Minter, address _l2messenger) CrossChainL2Minter(_l1Minter, _l2messenger) {}  
  constructor(address _l1Minter, address _l2messenger) ERC721("L2Root", "RT") CrossChainL2Minter(_l1Minter, _l2messenger) {}  

  // string [][] argsForMintNode;  
  // uint256[][] argsForMintNode;  
  uint256[] public argsForMintNode;
  uint16[] public argsForMintNodeUint8;
  string[] public argsForMintNodeUintAsStr;
  //TODO for test purspose remove in final implementation
  function mintTree(address owner, string[][] memory newTree) external override(ITreeMinter) {
    wasMintTreeCalled = 1;   
    ownerIncomingValue = owner; 

    // TODO: print what come in newTree exactly
    // transferedStringArrayData = newTree;
    //

    // uint256[] memory argsForMintNode = new uint256[](10);
    uint256 idx = 0;

    // TODO: add check that only Root address from L2 can send messages to this function (otherwise random people will mint whole trees)
    require(newTree.length > 1 && newTree[0].length > 1, "Tree for import must not be empty and must containt more than just a root");

    string memory rootHash = newTree[0][0];
    uint256 rootId = mintRoot(rootHash, owner);
    wasMintTreeCalled = rootId;   
    // argsForMintNode[idx] = 1; // looks like access to uint256 table is causing the L2 -> L1 call to hang

    for(uint i = 0; i < newTree.length; i++) {
      for(uint j = 1; j < newTree[i].length; j++) {
        // newTree[0][0] is root and its alredy minted above
        string memory ancestorHash = newTree[i][0]; // frist element in each row is the parent node, and follwing elements in the row as his descendants (adjecency list graph representaion)
        uint256 ancestorNodeId = hashes[ancestorHash];
        // argsForMintNode.push([ uint(ancestorNodeId), uint(rootId)]);
        // argsForMintNode.push(1); // this works
        argsForMintNode.push(ancestorNodeId); // this works
        // idx++;
        // argsForMintNode[idx] = ancestorNodeId; // this does not work
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

  string[][] public transferedStringArrayData;
  function crossChainStringArrayTransfer(address owner, string[][] memory data) external override {
    // argsForMintNodeUint8[0] = 1; // looks like any gobaly declared table modification with direct access (using []) is freezing L2 contract execution
                                    // TODO: will above work on L1 ? - no it also does not work, seems this kind of access to global arrays is not possible
    argsForMintNode.push(1);        // this works !  - but why ?
    // argsForMintNodeUintAsStr[0] = "1"; // does not work as well
    argsForMintNodeUintAsStr.push("1"); // this works !  - but why ?
    transferedStringArrayData = data;
  } 

  // function getArgsForMintNode() public view returns(string[][] memory) {
  function getArgsForMintNode() public view returns(uint256[] memory) {
    return argsForMintNode;
  }

  function getTransferredStringArrayData() public view returns(string[][] memory) {
    return transferedStringArrayData;
  }


//    function uint2str(
//   uint256 _i
// )
//   internal
//   pure
//   returns (string memory str)
// {
//   if (_i == 0)
//   {
//     return "0";
//   }
//   uint256 j = _i;
//   uint256 length;
//   while (j != 0)
//   {
//     length++;
//     j /= 10;
//   }
//   bytes memory bstr = new bytes(length);
//   uint256 k = length;
//   j = _i;
//   while (j != 0)
//   {
//     bstr[--k] = bytes1(uint8(48 + j % 10));
//     j /= 10;
//   }
//   str = string(bstr);
// }

    

}