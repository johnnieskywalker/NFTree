pragma solidity >=0.6.0 <0.8.0;
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
    // nodesInTreeByRoot[newRootId].push(newRootId);

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

  function mintNode(string memory hash, uint256 ancestorNodeId) public returns(uint256) {
    require(hashes[hash] != 1, "Can not use the same hash (Node check)");    

    nodesIds.increment();
    uint256 newNodeId = nodesIds.current();
    hashes[hash] = newNodeId;
    // console.log(rootId);
    // nodesInTreeByRoot[rootId].push(newNodeId);

    nodeOwner[newNodeId] = msg.sender;
    tree[ancestorNodeId].push(newNodeId);

    _mint(msg.sender, newNodeId);   // if will work on L2, change to _safeMint() - recommened method
    _setTokenURI(newNodeId, hash);
    return newNodeId;
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