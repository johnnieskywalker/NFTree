import { ethers } from "hardhat";
import { Root } from "../typechain/Root";
import { existsSync, mkdirSync, writeFileSync } from 'fs';
import { Contract } from "@ethersproject/contracts";
// how to properly use hre want to use readArtifactSync in TS :/
// import { HardhatRuntimeEnvironment } from "hardhat/types";
const hre = require("hardhat");

async function main() {
  const factory = await ethers.getContractFactory("Root");
  // if there would be any constructor params we would pass them here 
  let contract = await factory.deploy();
  console.log("Contract address : ", contract.address);
  // transaction used to sent contract to the blockchain
  console.log("Deployment transaction hash: ", contract.deployTransaction.hash);
  // The contract is NOT deployed yet; we must wait until it is mined
  await contract.deployed();

  generateFrontendFiles(contract);
}

function generateFrontendFiles(contract : Contract) {
  const contractsDirectory = __dirname+"/../frontend/src/contracts/";

  if (!existsSync(contractsDirectory)) {
    mkdirSync(contractsDirectory);
  }

  writeFileSync(contractsDirectory + "contract-address.json", JSON.stringify({ "Root": contract.address }, undefined, 2));

  // TODO: JOH add making ABI for frontend like in https://github.com/nomiclabs/hardhat-hackathon-boilerplate/blob/master/scripts/deploy.js
  // const RootArtifact = hre.readArtifactSync("Root");
  console.log("Hardhat config");
  console.log(hre.config);
  

}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
