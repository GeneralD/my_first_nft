// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

contract UpgradeableNFT_V2 is
    ERC721EnumerableUpgradeable,
    ERC721BurnableUpgradeable
{
    // Upgradeable contract can't have constractor
    function initialize() public initializer {
        __ERC721_init("Upgradeable NFT", "UGNFT");
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    )
        internal
        virtual
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable)
    {
        return super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721EnumerableUpgradeable, ERC721Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
