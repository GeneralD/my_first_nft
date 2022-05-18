// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

// V2 is not able to inherit class that was not interited in V1 and has storaged field.
contract UpgradeableNFT_V2 is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    OwnableUpgradeable
{
    using StringsUpgradeable for uint256;

    // These value will be inherited from V1
    uint256 public value;

    string public strValue;

    event Migrated(string);

    // Upgradeable contract can't have constractor
    function initialize(uint256 _value) public initializer {
        __UpgradeableNFT_V2_init("Upgradeable NFT", "UGNFT", _value);
    }

    function __UpgradeableNFT_V2_init(
        string memory _name,
        string memory _symbol,
        uint256 _value
    ) internal onlyInitializing {
        __ERC721_init(_name, _symbol);
        __ERC721Enumerable_init();
        __Ownable_init();

        __UpgradeableNFT_V2_init_unchained(_value);
    }

    function __UpgradeableNFT_V2_init_unchained(uint256 _value)
        internal
        onlyInitializing
    {
        value = _value;
    }

    /**
     * @dev function has reinitializer modifier also can run function has onlyInitializing
     */
    function migrate() public reinitializer(2) {
        strValue = value.toString();
        emit Migrated(strValue);
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
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
    {
        return super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
