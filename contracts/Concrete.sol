pragma solidity >=0.6.0 <0.8.0;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Base } from "./Base.sol";

import { CrossChainL2Minter } from "./CrossChainL2Minter.sol";

// contract Concrete is Base, ERC721 {  // Error : Linearization of inheritance graph impossible
contract Concrete is ERC721, Base, CrossChainL2Minter {

    uint internalVal;

    constructor(uint val, address fakeAddress) ERC721("Root", "RT") CrossChainL2Minter(fakeAddress, fakeAddress) {
        internalVal = val;
    }

    function addToVal(uint cnt) public returns(uint) {
        internalVal += cnt;
        return internalVal;
    }

    function readVal() view public returns(uint) {
        return internalVal;
    }

}