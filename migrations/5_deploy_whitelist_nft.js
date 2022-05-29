const WhitelistNFT = artifacts.require("nfts/WhitelistNFT")

const keccak256 = require('keccak256')
const { MerkleTree } = require('merkletreejs')

module.exports = function (deployer) {
    const tree = new MerkleTree([deployer.address], keccak256, { sort: true })
    const root = tree.getHexRoot()
    deployer.deploy(WhitelistNFT, root)
}
