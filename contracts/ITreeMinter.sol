pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

interface ITreeMinter {

  function mintTree(address owner, string[][] memory tree) external;

  function crossChainStringTransfer(address owner, string memory data) external;

  function crossChainStringArrayTransfer(address owner, string[][] memory data) external;

}
