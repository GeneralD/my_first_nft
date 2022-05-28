const { upgradeProxy } = require('@openzeppelin/truffle-upgrades')

const UpgradeableNFT_V1 = artifacts.require('nfts/UpgradeableNFT_V1')
const UpgradeableNFT_V2 = artifacts.require('nfts/UpgradeableNFT_V2')

module.exports = async function (deployer) {
    const deployed = await UpgradeableNFT_V1.deployed()
    const instance = await upgradeProxy(deployed.address, UpgradeableNFT_V2, { deployer })
    console.log('Upgraded', instance.address)
}