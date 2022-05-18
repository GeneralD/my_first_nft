const { deployProxy, upgradeProxy, deployBeacon, deployBeaconProxy, upgradeBeacon, erc1967 } = require('@openzeppelin/truffle-upgrades')
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
        assert.equal(instance.address, upgraded.address)
    })

    it("Upgrade a proxy and call function with onlyInitializing modifier", async function () {
        const instance = await deployProxy(ContractV1, [999])
        const upgraded = await upgradeProxy(instance.address, ContractV2, { call: { fn: 'migrate', args: [] } })

        assert.equal(await upgraded.value(), 999)
        assert.equal(await upgraded.strValue(), '999')
    })

    it("Upgrade a newed contract then failed", async function () {
        const instance = await ContractV1.new()
        await truffleAssert.fails(upgradeProxy(instance.address, ContractV2), `Contract at ${instance.address} doesn't look like an ERC 1967 proxy with a logic contract address`)
    })

    it("Deploy a beacon proxy and check a value of an instance", async function () {
        const beacon = await deployBeacon(ContractV1)
        const instance = await deployBeaconProxy(beacon.address, ContractV1, [777])

        assert.equal(await instance.value(), 777)
        assert.notEqual(beacon.address, instance.address)
    })

    it("Upgrade a beacon and call function with onlyInitializing modifier", async function () {
        const beacon = await deployBeacon(ContractV1)
        const instance = await deployBeaconProxy(beacon.address, ContractV1, [777])

        await upgradeBeacon(beacon.address, ContractV2)
        const upgraded = await ContractV2.at(instance.address)

        assert.equal(await upgraded.value(), 777)
        // assert.equal(await upgraded.strValue(), '777')
        assert.equal(instance.address, upgraded.address)
    })

    it("Get beacon address from a contract instance", async function () {
        const beacon = await deployBeacon(ContractV1)
        const instance = await deployBeaconProxy(beacon.address, ContractV1, [555])

        const beaconAddress = await erc1967.getBeaconAddress(instance.address)
        assert.equal(beaconAddress, beacon.address)
    })

    it("Get beacon address from a newed instance then failed", async function () {
        const instance = await ContractV1.new()
        await truffleAssert.fails(erc1967.getBeaconAddress(instance.address), `Contract at ${instance.address} doesn't look like an ERC 1967 beacon proxy`)
    })

    it("Get beacon address from a proxied instance then failed", async function () {
        const instance = await deployProxy(ContractV1, [555])
        await truffleAssert.fails(erc1967.getBeaconAddress(instance.address), `Contract at ${instance.address} doesn't look like an ERC 1967 beacon proxy`)
    })

    it("Get beacon address from a contract instance and upgrade", async function () {
        const beacon = await deployBeacon(ContractV1)
        const instance = await deployBeaconProxy(beacon.address, ContractV1, [555])

        const beaconAddress = await erc1967.getBeaconAddress(instance.address)
        await upgradeBeacon(beaconAddress, ContractV2)
        const upgraded = await ContractV2.at(instance.address)

        assert.equal(await upgraded.value(), 555)
        assert.equal(instance.address, upgraded.address)
    })
})
