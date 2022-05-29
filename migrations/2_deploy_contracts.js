const InvitationMembershipNFT = artifacts.require("nfts/InvitationMembershipNFT")
const LimitedInvitationMembershipNFT = artifacts.require("nfts/LimitedInvitationMembershipNFT")

module.exports = function (deployer) {
  deployer.deploy(InvitationMembershipNFT)
  deployer.deploy(LimitedInvitationMembershipNFT)
}
