import { ethers } from "hardhat";
import {Root} from "../typechain/Root"

async function main() {
  const factory = await ethers.getContractFactory("Root");
  // if there would be any constructor params we would pass them here 
  let contract = await factory.deploy();
  console.log("Contract address : ", contract.address);
  // transaction used to sent contract to the blockchain
  console.log("Deployment transaction hash: ", contract.deployTransaction.hash);
  // The contract is NOT deployed yet; we must wait until it is mined
  await contract.deployed();
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
