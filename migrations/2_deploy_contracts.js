const NFT = artifacts.require("nfts/NFT")
const InvitationMembershipNFT = artifacts.require("nfts/InvitationMembershipNFT")
const LimitedInvitationMembershipNFT = artifacts.require("nfts/LimitedInvitationMembershipNFT")

module.exports = function (deployer) {
  // deployer.deploy(NFT, "My First NFT", "MFNFT")
  deployer.deploy(InvitationMembershipNFT)
  deployer.deploy(LimitedInvitationMembershipNFT)
}
