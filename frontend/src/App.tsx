import React from 'react';
import logo from './logo.svg';
import './App.css';
// probabbly should use this one not hardhat
import { ethers } from "ethers";
import {Root} from "../../typechain/Root"

// import { ethers } from "hardhat";
const CONTRACT_ADDRESS = '0x5FbDB2315678afecb367f032d93F642f64180aa3';
const HARDHAT_NETWORK_ID = '31337';
declare let window: any;
declare let provider: any;


function App() {
  return (

    <div className="App">
     <form>
      <label>
        Root hash
        <input type="text" name="roothash" />
        </label>
        <br></br>
      <label>
        Node1 hash
        <input type="text" name="node1hash" />
        </label>
        <label>
          Node2 hash
           <input type="text" name="node2hash"/>
        </label>
        <label>
          Node3 hash
          <input type="text" name="node3hash" />
        </label>
        <br></br>
        <label>
          Node4 hash
           <input type="text" name="node4hash"/>
        </label>
        <br></br>
      <input type="submit" value="Mint NFTree" />
      </form>
    </div>
  );
}


export default App;
function _intializeEthers() {
  provider = new ethers.providers.Web3Provider(window.ethereum);
  
}