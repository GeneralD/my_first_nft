const NFT = artifacts.require("nfts/NFT")
const InvitationMembershipNFT = artifacts.require("nfts/InvitationMembershipNFT")

module.exports = function (deployer) {
  // deployer.deploy(ConvertLib)
  // deployer.link(ConvertLib, MetaCoin)
  // deployer.deploy(MetaCoin)

  // deployer.deploy(NFT, "My First NFT", "MFNFT")
  deployer.deploy(InvitationMembershipNFT)
}
