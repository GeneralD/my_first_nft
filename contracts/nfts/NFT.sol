// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/// @author Yumenosuke Kokata
/// @title A simple NFT
contract NFT is
    AccessControl,
    Ownable,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable,
    ERC721URIStorage
{
    using Strings for uint256;

    string private constant BASE_URI = "http://sample.com/";

    bytes32 public constant FINANCIAL_ROLE = keccak256("FINANCIAL_ROLE");
    bytes32 public constant FINANCIAL_ADMIN_ROLE =
        keccak256("FINANCIAL_ADMIN_ROLE");

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        // Granter roles
        _setRoleAdmin(FINANCIAL_ROLE, FINANCIAL_ADMIN_ROLE);

        // Grant all to the sender (owner)
        bytes32[2] memory roles = [FINANCIAL_ADMIN_ROLE, FINANCIAL_ROLE];
        for (uint256 i = 0; i < roles.length; i++) {
            _grantRole(roles[i], msg.sender);
        }
    }

    // Override Members

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override(ERC721URIStorage, ERC721)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721Enumerable, ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function burn(uint256 tokenId) public virtual override whenNotPaused {
        return super.burn(tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        virtual
        override(ERC721URIStorage, ERC721)
    {
        return super._burn(tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return BASE_URI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Pausable, ERC721Enumerable, ERC721) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev mint a new NFT
     */
    function mint(address to) public virtual {
        mint(to, 1);
    }

    /**
     * @dev mint some NFTs
     */
    function mint(address to, uint256 amount)
        public
        payable
        virtual
        onlyOwner
        whenNotPaused
    {
        // totalSupply works like auto incremented ID. It starts from 0.
        uint256 startTokenId = totalSupply();

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = startTokenId + i;
            _safeMint(to, tokenId);
            _setTokenURI(tokenId, string(abi.encodePacked(tokenId, ".json")));
        }
    }

    /**
     * @dev get all token ids of an adress
     */
    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 balance = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](balance);
        for (uint256 i; i < balance; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function withdraw() public payable onlyRole(FINANCIAL_ROLE) {
        require(payable(msg.sender).send(address(this).balance));
    }

    /**
     * @dev lock minting and burning
     */
    function pause() public onlyOwner {
        _pause();
    }

    /**
     * @dev unlock miniting and burning
     */
    function unpause() public onlyOwner {
        _unpause();
    }
}
