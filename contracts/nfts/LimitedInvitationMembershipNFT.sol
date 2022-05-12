// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./InvitationMembershipNFT.sol";

contract LimitedInvitationMembershipNFT is InvitationMembershipNFT {
    using Counters for Counters.Counter;
    mapping(address => Counters.Counter) private _memberInviteCount;

    uint256 private constant MAX_INVITE = 2;

    function mintAndTransfer(address _to) public override canInviteMore {
        super.mintAndTransfer(_to);
        _memberInviteCount[msg.sender].increment();
    }

    function getInvitationCount() external view returns (uint256) {
        return _memberInviteCount[msg.sender].current();
    }

    modifier canInviteMore() {
        require(
            msg.sender == owner() ||
                _memberInviteCount[msg.sender].current() < MAX_INVITE,
            "invitation limit exceeded"
        );
        _;
    }
}
