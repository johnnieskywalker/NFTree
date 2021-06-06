import { ethers } from "hardhat";
import chai from "chai";
import { solidity } from "ethereum-waffle";

import { Concrete } from "../typechain/Concrete"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

chai.use(solidity);     //TODO: ask Johnny how it works
const {expect} = chai;  //TODO: ask Johnny how it works

const contractName = "Concrete";


describe("Concrete", () => {
  let concrete: Concrete;
  let signer: SignerWithAddress

  beforeEach(async () => {
    const signers = await ethers.getSigners();    
    signer = signers[0];
    const contractFactory = await ethers.getContractFactory(contractName, signer);

    concrete = (await contractFactory.deploy(
      0, 
      { gasLimit: 8999999 }                     // same as above
    )) as Concrete;

    await concrete.deployTransaction.wait();
    const value = await concrete.readVal();

    expect(value).to.eq(0);
    expect(concrete.address).to.properAddress;
  });

  describe("verify deployment", async () => {
    it("should correctly read simple contract params", async () => {
      const value = await concrete.readVal();
      expect(value).to.eq(0);
      expect(concrete.address).to.properAddress;
    });
  });

  describe("verify Concrete class methods", async () => {
    it("should correctly add number to stored value", async () => {
      const tx1 = await concrete.addToVal(1);
      await tx1.wait();
      const tx2 = await concrete.addToVal(2);
      await tx2.wait();
      const currentVal = await concrete.readVal();
      expect(currentVal).to.eq(3);
    });
  });

  describe("verify Base class methods", async () => {
    it("should read root count", async () => {
      const rootCount = await concrete.getRootsCount();
      expect(rootCount).to.eq(0);
    });

    it("should add root", async () => {
      const tx1 = await concrete.mintRoot("0x1", signer.address);
      await tx1.wait();
      const rootCount = await concrete.getRootsCount();
      const hashValue = await concrete.readHashValue("0x1");
      expect(rootCount).to.eq(1);
      expect(hashValue).to.eq(1);
    });



  });

});


