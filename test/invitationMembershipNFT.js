const truffleAssert = require('truffle-assertions')
const Contract = artifacts.require("InvitationMembershipNFT")

contract('InvitationMembershipNFT', function (accounts) {

    it("Deployer of this contract can invite without any limitation", async function () {
        // instantiate by new() instead of deployed() to test in clean room
        const instance = await Contract.new()
        await instance.mintAndTransfer(accounts[1])
        assert.equal(await instance.ownerOf(1), accounts[1])
        assert.equal(await instance.getTotalSupply(), 1)
    })

    it("Address who has this NFT can invite someone", async function () {
        const instance = await Contract.new()
        await instance.mintAndTransfer(accounts[1])
        assert.equal(await instance.ownerOf(1), accounts[1])
        await instance.mintAndTransfer(accounts[2], { from: accounts[1] })
        assert.equal(await instance.ownerOf(2), accounts[2])
        assert.equal(await instance.getTotalSupply(), 2)
    })

    it("Address who doesn't have this NFT cannot invite anyone", async function () {
        const instance = await Contract.new()
        await truffleAssert.reverts(instance.mintAndTransfer(accounts[2], { from: accounts[1] }), "not a member")
    })
})
