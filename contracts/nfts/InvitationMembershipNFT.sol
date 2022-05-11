// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract InvitationMembershipNFT is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenCounter;

    constructor() ERC721("InvitationMembership", "VIP") {}

    modifier onlyOwnerOrMember() {
        require(
            msg.sender == owner() || balanceOf(msg.sender) >= 1,
            "not a member"
        );
        _;
    }

    function mintAndTransfer(address _to) public onlyOwnerOrMember {
        _tokenCounter.increment();

        uint256 _newItemId = _tokenCounter.current();
        _safeMint(msg.sender, _newItemId);
        safeTransferFrom(msg.sender, _to, _newItemId);
    }

    function getTotalSupply() external view returns (uint256) {
        return _tokenCounter.current();
    }
}
