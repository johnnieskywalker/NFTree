pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;  // which one is correct this or below pragma abicoder v2;  ???
// pragma abicoder v2;
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract BaseRoot is ERC721 {

  using Counters for Counters.Counter;
  Counters.Counter private nodesIds;

  // represnts a map of roots for feach owner, one onwer can have many roots
  mapping (address => uint256[]) private rootsByOwner;
  uint256[] private roots;
  // all nodes in the tree for given root (including root)
  mapping (uint256 => uint256[]) private nodesInTreeByRoot;
  // used to store owners for nodes - only owner can attach a new node to one of nodes of his tree
  mapping (uint256 => address) private nodeOwner;
  // represents a map node adjacents; root is also a node; each treee strarts with root and is DAG
  mapping (uint256 => uint256[]) private tree;
  // unique nft hashes to nodeId map
  mapping(string => uint256) public hashes;
  mapping(uint256 => string) public hashesByNodeId;

  function mintRoot(string memory hash, address owner) public returns (uint256) {
    require(hashes[hash] != 1, "Can not use the same hash (Root check)");

    nodesIds.increment();
    uint256 newRootId = nodesIds.current();
    hashes[hash] = newRootId;
    hashesByNodeId[newRootId] = hash;
    nodesInTreeByRoot[newRootId].push(newRootId);

    roots.push(newRootId);
    rootsByOwner[msg.sender].push(newRootId);
    nodeOwner[newRootId] = msg.sender;

    _mint(msg.sender, newRootId);     // if will work on L2, change to _safeMint() - recommened method
    _setTokenURI(newRootId, hash);
    // effectively this value will be lost for extranal caller (out of blockchain) becuase when blockchain transacion wil run TransactionReceipe will be returned for enduser
    // this value will be accessible if called from other contract 
    // if you want to return some value you need to use events // TODO: EVENT
    return newRootId;
  }

  /*** PUZZLE SOLVED for error - mintRoot not a function in ts tests
  * TypeChain which is building TS api for contract is not correctly handling function overloads 
  * so having two functions with the same name but different params will cause that TypeChain will not create api function for any of them
  ***/
  //TODO: can I use calldata for hahsh (as it is immutable) but I need to save it ?
  function mintRootWithHash(string calldata hash) public returns (uint256) {
    return mintRoot(hash, msg.sender);
  }

  function mintNode(string memory hash, uint256 ancestorNodeId, uint256 rootId) public returns(uint256) {
    require(hashes[hash] != 1, "Can not use the same hash (Node check)");    

    nodesIds.increment();
    uint256 newNodeId = nodesIds.current();
    hashes[hash] = newNodeId;
    hashesByNodeId[newNodeId] = hash;
    // console.log(rootId);
    nodesInTreeByRoot[rootId].push(newNodeId);

    nodeOwner[newNodeId] = msg.sender;
    tree[ancestorNodeId].push(newNodeId);

    _mint(msg.sender, newNodeId);   // if will work on L2, change to _safeMint() - recommened method
    _setTokenURI(newNodeId, hash);
    return newNodeId;
  }

  function buildTreeForExportWithNodeId(uint256 rootId) public view returns(uint256[][] memory) {
    uint treeSize = arraySizeForTree(rootId);
    uint256[][] memory resultTreeArray = new uint256[][](treeSize);

    uint j = 0;
    for(uint i = 0; i < nodesInTreeByRoot[rootId].length; i++) {
      uint256 nodeId = nodesInTreeByRoot[rootId][i];
      if(tree[nodeId].length > 0) {
        uint256[] memory nodeArrayTree = new uint256[](tree[nodeId].length + 1);
        nodeArrayTree[0] = nodeId;
        for(uint k = 0; k < tree[nodeId].length; k++) {
          nodeArrayTree[k + 1] = tree[nodeId][k];    
        }
        resultTreeArray[j] = nodeArrayTree;
        j++;
      }
    }

    return resultTreeArray;
  }

  function buildTreeForExportWithHash(uint256 rootId) public view returns(string[][] memory) {
    uint treeSize = arraySizeForTree(rootId);
    string[][] memory resultTreeArray = new string[][](treeSize);

    uint j = 0;
    for(uint i = 0; i < nodesInTreeByRoot[rootId].length; i++) {
      uint256 nodeId = nodesInTreeByRoot[rootId][i];
      if(tree[nodeId].length > 0) {
        string[] memory nodeArrayTree = new string[](tree[nodeId].length + 1);
        nodeArrayTree[0] = hashesByNodeId[nodeId];
        for(uint k = 0; k < tree[nodeId].length; k++) {
          nodeArrayTree[k + 1] = hashesByNodeId[tree[nodeId][k]];    
        }
        resultTreeArray[j] = nodeArrayTree;
        j++;
      }
    }

    return resultTreeArray;
  }

  function arraySizeForTree(uint256 rootId) private view returns(uint) {
    uint size = 0;
    for(uint i = 0; i < nodesInTreeByRoot[rootId].length; i++) {
      uint256 nodeId = nodesInTreeByRoot[rootId][i];
      if(tree[nodeId].length > 0) size++;
    }
    return size;
  }

  function getDescendants(uint256 nodeId) public view returns(uint256[] memory) {
    return tree[nodeId];
  }

  function getRootCount() public view returns(uint) {
    return roots.length;
  }

  function getRootsByOwner(address ownerAddr) public view returns(uint256[] memory) {
    return rootsByOwner[ownerAddr];
  }

  function getNodeOwner(uint256 nodeId) public view returns(address) {
    return nodeOwner[nodeId];
  } 

  function getNodeIdForHash(string calldata hash) public view returns(uint256) {
    return hashes[hash];
  }

}