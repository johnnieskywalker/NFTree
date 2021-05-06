import { ethers } from "hardhat";
// import { l2ethers } from "hardhat";
import chai from "chai";
import { solidity } from "ethereum-waffle";

import {Root} from "../typechain/Root"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

import delay = require("delay");

// const assertArrays = require('chai-arrays');  -- TODO: ask Johnny why thus import does not work ?
// chai.use(assertArrays);

chai.use(solidity);     //TODO: ask Johnny how it works
const {expect} = chai;  //TODO: ask Johnny how it works


describe("Root", () => {
  let root: Root;
  let signer: SignerWithAddress

  beforeEach(async () => {
    const signers = await ethers.getSigners();    
    signer = signers[0];
    const contractFactory = await ethers.getContractFactory("Root", signer);

    root = (await contractFactory.deploy({
      gasPrice: ethers.BigNumber.from('0'),  // TODO : not sure if necessary but was used in on other L2 example
      gasLimit: 8999999,                     // same as above
    })) as Root;

    // myContract = await YourContract.deploy({
      // gasPrice: ethers.BigNumber.from('0'),
      // gasLimit: 8999999,
    // });


    await root.deployed();
    const rootCount = await root.getRootCount();

    expect(rootCount).to.eq(0);
    expect(root.address).to.properAddress;
  });

  describe("verify deployment", async () => {
    it("should correctly read simple contract params", async () => {
      const rootCount = await root.getRootCount();
      expect(rootCount).to.eq(0);
      expect(root.address).to.properAddress;
    });
  });

 	
  describe("mintRoot", async () => {
    it("should mint new root", async () => {
      const testHash = "asasdasdas121212120x1"
      await root.mintRoot(testHash);
      await delay(100);

      const rootId = await root.hashes(testHash);
      // await delay(100);
      const rootCount = await root.getRootCount();
      // await delay(100);
      const ownerRoots = await root.getRootsByOwner(signer.address);
      // await delay(100);
      // const nodeOwner = await root.getNodeOwner(rootId);
      const rootNodeOwner = await root.getNodeOwner(rootId);

      expect(rootId).to.eq(1);
      expect(rootCount).to.eq(1);
      expect(ownerRoots.length).to.eq(1);
      expect(ownerRoots[0]).to.eq(rootId);
      expect(rootNodeOwner).to.eq(signer.address);
    });

    /**
     * This is partially fixed, it is still not catching the right exception, now it fails with :
     *  --> other exception was thrown: Error: cannot estimate gas; transaction may fail or may require manual gas limit
     * but at least it fails it the same way optimism examples are failing that test revert - so it's not bad ;)
     */
    it("should fail when minting new root with old hash", async () => {
      const testHash = "asasdasdas121212120x"
      await root.mintRoot(testHash);
      await delay(100);
      await expect(root.mintRoot(testHash)).to.be.revertedWith("VM Exception while processing transaction: revert Can not use the same hash");
    });

    it("should mint new node", async () => {
      const testHashRoot = "asdf1234";
      const testHashNodeOne = "XXX11";

      await root.mintRoot(testHashRoot);
      await delay(100);
      const rootId = await root.hashes(testHashRoot);   // switch to getNodeIdForHash, and make hashes private
      await root.mintNode(testHashNodeOne, rootId);
      await delay(100);

      const nodeOneId = await root.hashes(testHashNodeOne);
      const rootOwner = await root.getNodeOwner(nodeOneId);
      const nodeOneOwner = await root.getNodeOwner(nodeOneId);
      const rootDescendants = await root.getDescendants(rootId);
      
      expect(rootId).to.eq(1);  
      expect(nodeOneId).to.eq(2);  
      expect(rootOwner).to.eq(signer.address);  
      expect(rootOwner).to.eq(nodeOneOwner);
      expect(rootDescendants.length).to.eq(1);
      expect(rootDescendants[0]).to.eq(nodeOneId);
    });

    it("should mint new tree", async () => {
      const testHashRoot = "asdf1231";
      const testHashNodeOne = "XXX11";
      const testHashNodeTwo = "XXX21";
      const testHashNodeThree = "XXX31";
      const testHashNodeFour = "XXX41";

      await root.mintRoot(testHashRoot);
      await delay(100);
      const rootId = await root.getNodeIdForHash(testHashRoot);

      await root.mintNode(testHashNodeOne, rootId);
      await delay(100);
      const nodeOneId = await root.getNodeIdForHash(testHashNodeOne);  
      await root.mintNode(testHashNodeTwo, rootId);
      await delay(100);
      const nodeTwoId = await root.getNodeIdForHash(testHashNodeTwo);  
      await root.mintNode(testHashNodeThree, nodeOneId);
      await delay(100);
      const nodeThreeId = await root.getNodeIdForHash(testHashNodeThree);  
      await root.mintNode(testHashNodeFour, nodeThreeId);
      await delay(100);
      const nodeFourId = await root.getNodeIdForHash(testHashNodeFour);  

      const rootDescendants = await root.getDescendants(rootId);
      const nodeOneDescendants = await root.getDescendants(nodeOneId);
      const nodeTwoDescendants = await root.getDescendants(nodeTwoId);
      const nodeThreeDescendants = await root.getDescendants(nodeThreeId);
      const nodeFourDescendants = await root.getDescendants(nodeFourId);

      // BigNumber from ethers does not have correctly implemented Array.prototype.includes() nor Array.prototype.indexOf():
      expect(rootDescendants.length).to.eq(2);
      expect(rootDescendants.findIndex(el => el.toNumber() === nodeOneId.toNumber())).to.gt(-1);
      expect(rootDescendants.findIndex(el => el.toNumber() === nodeTwoId.toNumber())).to.gt(-1);
      expect(nodeOneDescendants.length).to.eq(1);
      expect(nodeOneDescendants.findIndex(el => el.toNumber() === nodeThreeId.toNumber())).to.gt(-1);
      expect(nodeTwoDescendants.length).to.eq(0);
      expect(nodeThreeDescendants.length).to.eq(1);
      expect(nodeThreeDescendants.findIndex(el => el.toNumber() === nodeFourId.toNumber())).to.gt(-1);
      expect(nodeFourDescendants.length).to.eq(0);
      /**
       * Tree:
       *        r
       *       / \
       *      1   2
       *     /  
       *    3  
       *   /
       *  4
       */
    });


    //TODO: test for many owners (users)


  });

});


