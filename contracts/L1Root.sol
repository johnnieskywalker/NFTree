pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// import { BaseRoot } from "./BaseRoot.sol";
import { IL1Minter } from "./IL1Minter.sol";

// contract L1Root is BaseRoot, IL1Minter {
contract L1Root is ERC721 {

  // constructor() BaseRoot() {}

  uint8 public wasMintTreeCalled;
  address public ownerIncomingValue;

  using Counters for Counters.Counter;
  Counters.Counter private nodesIds;

  // represnts a map of roots for feach owner, one onwer can have many roots
  mapping (address => uint256[]) private rootsByOwner;
  uint256[] private roots;
  // all nodes in the tree for given root (including root)
  // mapping (uint256 => uint256[]) private nodesInTreeByRoot;
  // used to store owners for nodes - only owner can attach a new node to one of nodes of his tree
  mapping (uint256 => address) private nodeOwner;
  // represents a map node adjacents; root is also a node; each treee strarts with root and is DAG
  mapping (uint256 => uint256[]) private tree;
  // unique nft hashes to nodeId map
  mapping(string => uint256) public hashes;

  constructor () ERC721("Root", "RT") {}


  // function mintTree(address owner, string[][] memory tree) external override {
  //   wasMintTreeCalled = 1;   
  //   ownerIncomingValue = owner; 

  //   // TODO: add check that only Root address from L2 can send messages to this function (otherwise random people will mint whole trees)
  //   require(tree.length > 1 && tree[0].length > 1, "Tree for import must not be empty and must containt more than just a root");

  //   string memory rootHash = tree[0][0];
  //   uint256 rootId = mintRoot(rootHash, owner);

  //   for(uint i = 0; i < tree.length; i++) {
  //     for(uint j = 0; j < tree[i].length; j++) {
  //       if(i != 0 && j !=0) {               // tree[0][0] is root and its alredy minted above
  //         string memory ancestorHash = tree[i][0]; // frist element in each row is the parent node, and follwing elemesnts in the row as his descendants (adjecency list graph representaion)
  //         uint256 ancestorNodeId = hashes[ancestorHash];
  //         // mintNode(tree[i][j], ancestorNodeId, rootId);
  //         // mintNode(tree[i][j], ancestorNodeId);
  //       }    
  //     }    
  //   }
  // }


  // function mintRoot(string memory hash, address owner) public returns (uint256) {
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

  //TODO: can I use calldata for hahsh (as it is immutable) but I need to save it ?
  function mintRoot(string calldata hash) public returns (uint256) {
    mintRoot(hash, msg.sender);
  }

  // function mintNode(string memory hash, uint256 ancestorNodeId, uint rootId) public returns(uint256) {
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