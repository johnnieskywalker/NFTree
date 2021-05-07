pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

interface IL1Minter {

  function mintTree(address owner, string[][] memory tree) external;

}
