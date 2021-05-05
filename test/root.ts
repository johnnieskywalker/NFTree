import { ethers } from "hardhat";
import chai from "chai";
import { solidity } from "ethereum-waffle";

import {Root} from "../typechain/Root"
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

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

    root = (await contractFactory.deploy()) as Root;
    await root.deployed();
    const rootCount = await root.getRootCount();

    expect(rootCount).to.eq(0);
    expect(root.address).to.properAddress;
  });


  describe("mintRoot", async () => {
    it("should mint new root", async () => {
      const testHash = "asasdasdas121212120x"
      await root.mintRoot(testHash);
      
      const rootId = await root.hashes(testHash);
      const rootCount = await root.getRootCount();
      const ownerRoots = await root.getRootsByOwner(signer.address);
      // const nodeOwner = await root.getNodeOwner(rootId);
      const rootNodeOwner = await root.getNodeOwner(rootId);

      expect(rootId).to.eq(1);
      expect(rootCount).to.eq(1);
      expect(ownerRoots.length).to.eq(1);
      expect(ownerRoots[0]).to.eq(rootId);
      expect(rootNodeOwner).to.eq(signer.address);
    });

    it("should fail when minting new root with old hash", async () => {
      const testHash = "asasdasdas121212120x"
      await root.mintRoot(testHash);
      
      await expect(root.mintRoot(testHash)).to.be.revertedWith("VM Exception while processing transaction: revert Can not use the same hash");
    });

    it("should mint new node", async () => {
      const testHashRoot = "asdf123";
      const testHashNodeOne = "XXX1";

      await root.mintRoot(testHashRoot);
      const rootId = await root.hashes(testHashRoot);   // switch to getNodeIdForHash, and make hashes private
      await root.mintNode(testHashNodeOne, rootId);

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
      const testHashRoot = "asdf123";
      const testHashNodeOne = "XXX1";
      const testHashNodeTwo = "XXX2";
      const testHashNodeThree = "XXX3";
      const testHashNodeFour = "XXX4";

      await root.mintRoot(testHashRoot);
      const rootId = await root.getNodeIdForHash(testHashRoot);

      await root.mintNode(testHashNodeOne, rootId);
      const nodeOneId = await root.getNodeIdForHash(testHashNodeOne);  
      await root.mintNode(testHashNodeTwo, rootId);
      const nodeTwoId = await root.getNodeIdForHash(testHashNodeTwo);  
      await root.mintNode(testHashNodeThree, nodeOneId);
      const nodeThreeId = await root.getNodeIdForHash(testHashNodeThree);  
      await root.mintNode(testHashNodeFour, nodeThreeId);
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


