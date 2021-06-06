pragma solidity >=0.6.0 <0.8.0;
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/Counters.sol";
import { Base } from "./Base.sol";

contract Concrete is Base {

    uint internalVal;

    constructor(uint val) {
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