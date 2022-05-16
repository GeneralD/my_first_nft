// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";

contract UpgradeableNFT_V2 is
    ERC721Upgradeable,
    OwnableUpgradeable,
    ERC721EnumerableUpgradeable,
    ERC721BurnableUpgradeable
{
    // These value will be inherited from V1
    uint256 public value;

    // Upgradeable contract can't have constractor
    function initialize(uint256 _value1, uint256 _value2) public initializer {
        __ERC721_init("Upgradeable NFT", "UGNFT");
        __Ownable_init();
        __ERC721Enumerable_init();
        __ERC721Burnable_init();

        _initializeFields(_value1 + _value2);
    }

    /**
     * @dev function has onlyInitializing modifier can be executed from function has initializer
     */
    function _initializeFields(uint256 _value) private onlyInitializing {
        value = _value;
    }

    /**
     * @dev function has reinitializer modifier also can run function has onlyInitializing
     */
    function migrate() public onlyOwner reinitializer(2) {
        _initializeFields(value * 2);
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
