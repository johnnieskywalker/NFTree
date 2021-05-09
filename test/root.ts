import { ethers } from "hardhat";
import chai from "chai";
import { solidity } from "ethereum-waffle";

// import {L2Root as Root} from "../typechain-ovm/L2Root"
// import {L1Root as Root} from "../typechain/L1Root"
import {L1Root } from "../typechain/L1Root"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

import delay = require("delay");

// const assertArrays = require('chai-arrays');  -- TODO: ask Johnny why thus import does not work ?
// chai.use(assertArrays);

chai.use(solidity);     //TODO: ask Johnny how it works
const {expect} = chai;  //TODO: ask Johnny how it works


describe("L1Root", () => {
  let root: L1Root;
  let signer: SignerWithAddress

  beforeEach(async () => {
    const signers = await ethers.getSigners();    
    signer = signers[0];
    const contractFactory = await ethers.getContractFactory("L1Root", signer);

    root = (await contractFactory.deploy({
      gasPrice: ethers.BigNumber.from('0'),  // TODO : not sure if necessary but was used in on other L2 example
      gasLimit: 8999999,                     // same as above
    })) as L1Root;

    await root.deployTransaction.wait();
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
      const testHash = "asasdasdas121212120x"
      const tx = await root.mintRoot(testHash);
      await tx.wait()

      const rootId = await root.hashes(testHash);
      const rootCount = await root.getRootCount();
      const ownerRoots = await root.getRootsByOwner(signer.address);
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
      const testHash = "asasdasdas12121210x"
      const tx1 = await root.mintRoot(testHash);
      await tx1.wait()
      
      const tx2 = root.mintRoot(testHash, { gasLimit: 8999999 })
      await expect(tx2).to.be.revertedWith("VM Exception while processing transaction: revert Can not use the same hash");
    });

    it("should mint new node", async () => {
      const testHashRoot = "asdf123";
      const testHashNodeOne = "XXX1";

      const tx1 = await root.mintRoot(testHashRoot);
      await tx1.wait()
      const rootId = await root.hashes(testHashRoot);   // switch to getNodeIdForHash, and make hashes private
      // const tx2 = await root.mintNode(testHashNodeOne, 1111);
      const tx2 = await root.mintMyHead(testHashNodeOne, rootId);
      // const tx2 = await root.mintNode(testHashNodeOne, rootId);
      await tx2.wait()

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

    /*

    it("should mint new tree", async () => {
      const testHashRoot = "asdf123";
      const testHashNodeOne = "XXX1";
      const testHashNodeTwo = "XXX2";
      const testHashNodeThree = "XXX3";
      const testHashNodeFour = "XXX4";

      const tx = await root.mintRoot(testHashRoot);
      await tx.wait()
      const rootId = await root.getNodeIdForHash(testHashRoot);

      // const tx1 = await root.mintNode(testHashNodeOne, rootId, rootId);
      const tx1 = await root.mintNode(testHashNodeOne, rootId);
      await tx1.wait()
      const nodeOneId = await root.getNodeIdForHash(testHashNodeOne);  
      // const tx2 = await root.mintNode(testHashNodeTwo, rootId, rootId);
      const tx2 = await root.mintNode(testHashNodeTwo, rootId);
      await tx2.wait()
      const nodeTwoId = await root.getNodeIdForHash(testHashNodeTwo);  
      // const tx3 = await root.mintNode(testHashNodeThree, nodeOneId, rootId);
      const tx3 = await root.mintNode(testHashNodeThree, nodeOneId);
      await tx3.wait()
      const nodeThreeId = await root.getNodeIdForHash(testHashNodeThree);  
      // const tx4 = await root.mintNode(testHashNodeFour, nodeThreeId, rootId);
      const tx4 = await root.mintNode(testHashNodeFour, nodeThreeId);
      await tx4.wait()
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
    // });

  


    //TODO: test for many owners (users)


  });

});


