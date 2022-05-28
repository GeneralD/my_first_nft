const OracleMadeNFT = artifacts.require("nfts/OracleMadeNFT")

module.exports = function (deployer) {
    deployer.deploy(OracleMadeNFT)
}
