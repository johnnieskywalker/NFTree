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

  function mintRoot(string memory hash, address owner) public returns (uint256) {
    require(hashes[hash] != 1, "Can not use the same hash (Root check)");

    nodesIds.increment();
    uint256 newRootId = nodesIds.current();
    hashes[hash] = newRootId;
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
    // console.log(rootId);
    nodesInTreeByRoot[rootId].push(newNodeId);

    nodeOwner[newNodeId] = msg.sender;
    tree[ancestorNodeId].push(newNodeId);

    _mint(msg.sender, newNodeId);   // if will work on L2, change to _safeMint() - recommened method
    _setTokenURI(newNodeId, hash);
    return newNodeId;
  }

  // TODO remove comment if the code works
  /* 
    Dynamic arrays must have a fixed size during creation, in our case second first dimension that needs to specified is number of descendants for node
    in this naive implementation we use total number of nodes in the tree as the worst case. 
    Optimal would be to calculate the longest path in the tree and use this value.
   */
  function buildTreeForExport(uint256 rootId) public view returns(uint256[][] memory) {
    //TODO: try to remove the open brackets
    uint256[] memory nodesByRoot = nodesInTreeByRoot[rootId];
    // uint treeSize = (nodesInTreeByRoot[rootId]).length * 2;   // max len when tree is a list (each node has one descendant)
    uint treeSize = nodesByRoot.length * 2;   // max len when tree is a list (each node has one descendant)
    uint256[][] memory treeArray = new uint256[][](treeSize);

    //TODO: optimize code check if nodeTree new array can be replaced with tree[nodeId]
    uint j = 0;
    for(uint i = 0; i < nodesByRoot.length; i++) {
      uint256 nodeId = nodesByRoot[i];
      if(tree[nodeId].length > 0) {
        uint256[] memory nodeTree = tree[nodeId]; 
        uint256[] memory nodeArrayTree = new uint256[](nodeTree.length + 1);
        // treeArray[j][0] = nodeId;
        nodeArrayTree[0] = nodeId;
        for(uint k = 0; k < nodeTree.length; k++) {
          nodeArrayTree[k + 1] = nodeTree[k];    
        }
        // treeArray[j] = tree[nodeId];
        treeArray[j] = nodeArrayTree;
        j++;
      }
    }

    return treeArray;
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