pragma solidity >=0.6.0 <0.8.0;
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { Base } from "./Base.sol";

// contract Concrete is Base, ERC721 {  // Error : Linearization of inheritance graph impossible
contract Concrete is ERC721, Base {

    uint internalVal;

    constructor(uint val) ERC721("Root", "RT") {
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