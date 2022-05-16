const { deployProxy } = require('@openzeppelin/truffle-upgrades')

const UpgradeableNFT_V1 = artifacts.require('UpgradeableNFT_V1')

module.exports = async function (deployer) {
    const instance = await deployProxy(UpgradeableNFT_V1, [99, 999], { deployer })
    console.log('Deployed', instance.address)
}