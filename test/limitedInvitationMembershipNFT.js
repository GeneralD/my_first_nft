const truffleAssert = require('truffle-assertions')
const Contract = artifacts.require("LimitedInvitationMembershipNFT")

contract('LimitedInvitationMembershipNFT', function (accounts) {

    it("Deployer of this contract can invite without any limitation", async function () {
        // instantiate by new() instead of deployed() to test in clean room
        const instance = await Contract.new()
        // owner invites many guys excluding himself
        for (let i = 1; i < Math.min(accounts.length, 10); i++) {
            await instance.mintAndTransfer(accounts[i])
            assert.equal(await instance.ownerOf(i), accounts[i])
            assert.equal(await instance.getTotalSupply(), i)
            assert.equal(await instance.getInvitationCount(), i)
        }
    })

    it("Address who has this NFT can invite 2 guys at most", async function () {
        const instance = await Contract.new()
        // owner invites 1st guy
        await instance.mintAndTransfer(accounts[1])
        assert.equal(await instance.ownerOf(1), accounts[1])
        // then, 1st guy invites 2nd guy
        await instance.mintAndTransfer(accounts[2], { from: accounts[1] })
        assert.equal(await instance.ownerOf(2), accounts[2])
        // and 3rd buy
        await instance.mintAndTransfer(accounts[3], { from: accounts[1] })
        assert.equal(await instance.ownerOf(3), accounts[3])
        // 1st guy exceeds to invitation limit
        await truffleAssert.reverts(instance.mintAndTransfer(accounts[4], { from: accounts[1] }), "invitation limit exceeded")
        assert.equal(await instance.getTotalSupply(), 3)
        // 1st guy suceeded to invite only 2 guys
        assert.equal(await instance.getInvitationCount({ from: accounts[1] }), 2)
    })

    it("Address who doesn't have this NFT cannot invite anyone", async function () {
        const instance = await Contract.new()
        await truffleAssert.reverts(instance.mintAndTransfer(accounts[2], { from: accounts[1] }), "not a member")
    })
})
