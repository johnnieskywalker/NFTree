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
  }

}