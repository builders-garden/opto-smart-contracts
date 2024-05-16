import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre, { ethers } from "hardhat";
import { createTestClient } from "viem";
import { mine } from "@nomicfoundation/hardhat-network-helpers";


describe("Opto", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployOpto() {

    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await hre.ethers.getSigners();

    const Opto = await hre.ethers.getContractFactory("OptoMock");
    const opto = await Opto.deploy(owner, otherAccount);
    const init = await opto.init(owner, "300000", "0x66756e2d657468657265756d2d6d61696e6e65742d3100000000000000000000", "2688");

    return { opto, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { opto, owner, otherAccount } = await loadFixture(deployOpto);
      expect(await opto.owner()).to.equal(owner);
      expect(await opto.usdcAddress()).to.equal(owner);
    });
    /*it("Should create options", async function () {
      const { opto, owner, otherAccount } = await loadFixture(deployOpto);
      const premium = "1000000";
      const strikePrice = "1"
      const buyDeadline = "2688000000000000"
      const expirationDate = "2688000000000001"
      const optionType = "1"
      const optionQueryId = "1"
      const optionAssetId = "1"
      const units = "10"
      const capPerUnit = "3000000"
      const options = await opto.createOption(true, premium, strikePrice, buyDeadline, expirationDate, optionType, optionQueryId, optionAssetId, units, capPerUnit);
      expect((await opto.options("1")).premium).to.equal(premium);
      expect((await opto.options("1")).statuses).to.equal("0x08"); // not active, not has to pay, not paused, call option
    });*/
    /*it("Should create and buy options", async function () {
      const { opto, owner, otherAccount } = await loadFixture(deployOpto);
      // block
      const blockNumBefore = await ethers.provider.getBlockNumber();
      const blockBefore = await ethers.provider.getBlock(blockNumBefore);
      const timestampBefore = blockBefore!.timestamp;
      // params
      const premium = "1000000";
      const strikePrice = "1"
      const buyDeadline = timestampBefore+3600
      const expirationDate = buyDeadline+7200
      const optionType = "1"
      const optionQueryId = "1"
      const optionAssetId = "1"
      const units = "10"
      const capPerUnit = "3000000"

      const options = await opto.createOption(true, premium, strikePrice, buyDeadline, expirationDate, optionType, optionQueryId, optionAssetId, units, capPerUnit);
      expect((await opto.options("1")).premium).to.equal(premium);
      expect((await opto.options("1")).statuses).to.equal("0x08"); // not active, not has to pay, not paused, call option
      const buy = await opto.buyOption("1", "1");
      expect((await opto.options("1")).statuses).to.equal("0x0a"); // active, has to pay, not paused, call option
    });*/
    /*it("Should create, buy options and check upkeep", async function () {
      const { opto, owner, otherAccount } = await loadFixture(deployOpto);
      // block
      const blockNumBefore = await ethers.provider.getBlockNumber();
      const blockBefore = await ethers.provider.getBlock(blockNumBefore);
      const timestampBefore = blockBefore!.timestamp;
      console.log("timestampBefore: ", timestampBefore)
      // params
      const premium = "1000000";
      const strikePrice = "1"
      const buyDeadline = timestampBefore+3600
      const expirationDate = buyDeadline+7200
      const optionType = "1"
      const optionQueryId = "1"
      const optionAssetId = "1"
      const units = "10"
      const capPerUnit = "3000000"
      // batch create options
      for (let i = 1; i < 10; i++) {
        console.log("counter: ", i.toString())
        const options = await opto.createOption(true, premium, strikePrice, buyDeadline, expirationDate, optionType, optionQueryId, optionAssetId, units, capPerUnit);
        expect((await opto.options(i.toString())).premium).to.equal(premium);
        expect((await opto.options(i.toString())).statuses).to.equal("0x08"); // not active, not has to pay, not paused, call option
        const buy = await opto.buyOption(i.toString(), "1");
        expect((await opto.options(i.toString())).statuses).to.equal("0x0a"); // active, not has to pay, not paused, call option
        console.log("counter: ", i.toString())
        const balance = await opto.balanceOfBatch([owner], [i.toString()]);
        expect(balance.toString()).to.equal("1");
        console.log("balance: ", balance.toString())        
      }
      //skip time
      await time.increase(buyDeadline+8200);
      // block
      const blockNumAfter = await ethers.provider.getBlockNumber();
      const blockAfter = await ethers.provider.getBlock(blockNumAfter);
      const timestampAfter = blockAfter!.timestamp;
      console.log("timestampAfter: ", timestampAfter)
      // batch check, perform upkeep, fulfill request
      for (let i = 1; i < 10; i++) {
        // check upkeep
        const checkUpkeep = await opto.checkUpkeep("0x");
        console.log("checkUpkeep needed: ", checkUpkeep[0])
        console.log("checkUpkeep value: ", checkUpkeep[1])
        // perform upkeep
        const staticPerformUpkeeep = await opto.performUpkeeep.staticCall(checkUpkeep[1]);
        console.log("request Id: ", staticPerformUpkeeep)
        const performUpkeeep = await opto.performUpkeeep(checkUpkeep[1]);
        const optionId = await opto.requestIds(staticPerformUpkeeep);
        console.log("optionId: ", optionId)
        const statusPre = (await opto.options(optionId)).statuses;
        console.log("status pre", statusPre)
        expect(statusPre).to.equal("0x0a")
        // fulfill request
        const fillRequest = await opto.fulfilllRequest(staticPerformUpkeeep, "0x0000000000000000000000000000000000000000000000000000000000000002", "0x");
        const statusPost = (await opto.options(optionId)).statuses;
        expect(statusPost).to.equal("0x08"); // active, has to pay, not paused, call option
        console.log("status post", statusPost)
        const checkUpkeep2 = await opto.checkUpkeep("0x");
        console.log("checkUpkeep2: ", checkUpkeep2[1])
      }
    });    */
    it("Should create, buy options and check upkeep with error response", async function () {
      const { opto, owner, otherAccount } = await loadFixture(deployOpto);
      // block
      const blockNumBefore = await ethers.provider.getBlockNumber();
      const blockBefore = await ethers.provider.getBlock(blockNumBefore);
      const timestampBefore = blockBefore!.timestamp;
      console.log("timestampBefore: ", timestampBefore)
      // params
      const premium = "1000000";
      const strikePrice = "1"
      const buyDeadline = timestampBefore+3600
      const expirationDate = buyDeadline+7200
      const optionType = "1"
      const optionQueryId = "1"
      const optionAssetId = "1"
      const units = "10"
      const capPerUnit = "3000000"
      // batch create options
      for (let i = 1; i < 10; i++) {
        console.log("counter: ", i.toString())
        const options = await opto.createOption(true, premium, strikePrice, buyDeadline, expirationDate, optionType, optionQueryId, optionAssetId, units, capPerUnit);
        expect((await opto.options(i.toString())).premium).to.equal(premium);
        expect((await opto.options(i.toString())).statuses).to.equal("0x08"); // not active, not has to pay, not paused, call option
        const buy = await opto.buyOption(i.toString(), "1");
        expect((await opto.options(i.toString())).statuses).to.equal("0x0a"); // active, not has to pay, not paused, call option
        console.log("counter: ", i.toString())
        const balance = await opto.balanceOfBatch([owner], [i.toString()]);
        expect(balance.toString()).to.equal("1");
        console.log("balance: ", balance.toString())        
      }
      //skip time
      await time.increase(buyDeadline+8200);
      // block
      const blockNumAfter = await ethers.provider.getBlockNumber();
      const blockAfter = await ethers.provider.getBlock(blockNumAfter);
      const timestampAfter = blockAfter!.timestamp;
      console.log("timestampAfter: ", timestampAfter)
      // batch check, perform upkeep, fulfill request
      for (let i = 1; i < 10; i++) {
        // check upkeep
        const checkUpkeep = await opto.checkUpkeep("0x");
        console.log("checkUpkeep needed: ", checkUpkeep[0])
        console.log("checkUpkeep value: ", checkUpkeep[1])
        // perform upkeep
        const staticPerformUpkeeep = await opto.performUpkeeep.staticCall(checkUpkeep[1]);
        console.log("request Id: ", staticPerformUpkeeep)
        const performUpkeeep = await opto.performUpkeeep(checkUpkeep[1]);
        const optionId = await opto.requestIds(staticPerformUpkeeep);
        console.log("optionId: ", optionId)
        const statusPre = (await opto.options(optionId)).statuses;
        console.log("status pre", statusPre)
        expect(statusPre).to.equal("0x0a")
        // fulfill request
        const fillRequest = await opto.fulfilllRequest(staticPerformUpkeeep, "0x0000000000000000000000000000000000000000000000000000000000000002", "0x0000000000000000000000000000000000000000000000000000000000000002");
        const statusPost = (await opto.options(optionId)).statuses;
        console.log("status post", statusPost)
        const staticClaim = await opto.claimForPausedOption.staticCall(optionId, 1, false);
        console.log("staticClaim: ", staticClaim)
        const claim = await opto.claimForPausedOption(optionId, 1, false);
        expect(opto.claimForPausedOption(optionId, 1, false)).to.be.revertedWith("Option does not have to pay");     
        expect(statusPost).to.equal("0x0d"); // not active, has to pay, paused, call option
        console.log("status post", statusPost)
        const checkUpkeep2 = await opto.checkUpkeep("0x");
        console.log("checkUpkeep2: ", checkUpkeep2[1])
      }
    }); 
  });
});