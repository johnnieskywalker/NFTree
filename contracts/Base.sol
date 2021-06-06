pragma solidity >=0.6.0 <0.8.0;
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract Base is ERC721 {

  using Counters for Counters.Counter;
  Counters.Counter private nodesIds;

  uint256[] private roots;
  // unique nft hashes to nodeId map
  mapping(string => uint256) public hashes;

  // constructor () ERC721("Root", "RT") {}

  function mintRoot(string calldata hash, address owner) public returns (uint256) {
    require(hashes[hash] != 1, "Can not use the same hash (Root check)");

    nodesIds.increment();
    uint256 newRootId = nodesIds.current();
    hashes[hash] = newRootId;
    roots.push(newRootId);

    return newRootId;
  }

  function getRootsCount() public view returns(uint) {
    return roots.length;
  }

  function readHashValue(string memory hashKey) public view returns(uint) {
    return hashes[hashKey];
  }

}