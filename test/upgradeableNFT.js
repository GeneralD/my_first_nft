const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades')
const truffleAssert = require('truffle-assertions')
const ContractV1 = artifacts.require('UpgradeableNFT_V1')
const ContractV2 = artifacts.require('UpgradeableNFT_V2')

contract('LimitedInvitationMembershipNFT', function (accounts) {

    it("Deploy a contract V1 and check a value", async function () {
        const instance = await deployProxy(ContractV1, [999])
        assert.equal(await instance.value(), 999)
    })

    it("Deploy a contract V2 and check a value", async function () {
        const instance = await deployProxy(ContractV2, [999])
        assert.equal(await instance.value(), 999)
    })

    it("Upgrade a contract from V1 to V2 and check a value is inherited", async function () {
        const instance = await deployProxy(ContractV1, [999])
        const upgraded = await upgradeProxy(instance.address, ContractV2)
        assert.equal(await upgraded.value(), 999)
    })


    it("Upgrade a contract from V1 to V2 and call function with onlyInitializing modifier", async function () {
        const instance = await deployProxy(ContractV1, [999])
        const upgraded = await upgradeProxy(instance.address, ContractV2, { call: { fn: 'migrate', args: [] } })
        assert.equal(await upgraded.value(), 999)
        assert.equal(await upgraded.strValue(), '999')
    })
})
