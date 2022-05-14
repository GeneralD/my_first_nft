const { deployProxy, upgradeProxy } = require('@openzeppelin/truffle-upgrades')

const UpgradeableNFT_V1 = artifacts.require('UpgradeableNFT_V1')
const UpgradeableNFT_V2 = artifacts.require('UpgradeableNFT_V2')

module.exports = async function (deployer) {
    const instance = await deployProxy(UpgradeableNFT_V1, [], { deployer })
    const upgraded = await upgradeProxy(instance.address, UpgradeableNFT_V2, { deployer })
}