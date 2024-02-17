import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
  import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
  import { expect } from "chai";
  import { ethers } from "hardhat";

describe("staking", () => {

    const deployStakingContract = async () => {
 
         const [owner, otherAccount] = await ethers.getSigners();
         
         const Token = await ethers.getContractFactory('ManoToken');
 
         const token = await Token.deploy(owner);
 
         const Staking = await ethers.getContractFactory("Staking");
 
         const staking= await Staking.deploy(1, token.target);
 
         return {staking, token, owner, otherAccount};
    }

    describe("stake function", () => {
        it("should stake ManoToken to stakingContract", async () => {
            const {staking, token, owner, otherAccount} = await loadFixture(deployStakingContract);

            const balBeforeStaking = (await staking.checkUserStakeInfo(owner)).amountStaked;

            await token.approve(staking.target, 200)

            await staking.connect(owner).stake(200);

            const balAfterStaking = (await staking.checkUserStakeInfo(owner)).amountStaked;

            await expect(balAfterStaking).to.be.greaterThan(balBeforeStaking);
        })

        it("balanceOf user in token contract should reduce after staking", async () => {
            const {staking, token, owner, otherAccount} = await loadFixture(deployStakingContract);

            const balBeforeStaking = await token.balanceOf(owner);

            await token.approve(staking.target, 200)

            await staking.connect(owner).stake(200);

            const balAfterStaking = await token.balanceOf(owner) ;

            await expect(balBeforeStaking).to.be.greaterThan(balAfterStaking);
        })

        it("should revert if staked amount is zero", async () => {
            const {staking, token, owner, otherAccount} = await loadFixture(deployStakingContract);

            await token.approve(staking.target, 200)

            await expect(staking.connect(owner).stake(0)).revertedWithCustomError(staking, "INVALID_AMOUNT()");


        })
    })

    describe("calculateReward func", () => {
        it("should calculate reward", async () => {
            const {staking, token, owner, otherAccount} = await loadFixture(deployStakingContract);

            await token.approve(staking.target, 200)

            await staking.connect(owner).stake(200);

            await expect(await staking.connect(owner).calculateReward())
        })
    })

})