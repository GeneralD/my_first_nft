const OracleMadeNFT = artifacts.require("nfts/OracleMadeNFT")
const StringUtils = artifacts.require("utils/StringUtils")

module.exports = function (deployer) {
    deployer.deploy(StringUtils)
    deployer.link(StringUtils, OracleMadeNFT)
    deployer.deploy(OracleMadeNFT)
}
