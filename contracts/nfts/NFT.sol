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
    uint256 private constant COST = 1 ether;
    uint256 private constant MINT_AMOUNT_LIMIT = 20;
    uint256 private constant MAX_SUPPLY = 10_000;

    bytes32 public constant FINANCIAL_ROLE = keccak256("FINANCIAL_ROLE");
    bytes32 public constant FINANCIAL_ADMIN_ROLE =
        keccak256("FINANCIAL_ADMIN_ROLE");

    bytes32 public constant WHITELIST_ADMIN_ROLE =
        keccak256("WHITELIST_ADMIN_ROLE");
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");
    bytes32 public constant WHITELISTED_MEMBER =
        keccak256("WHITELISTED_MEMBER");

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        // Granter roles
        _setRoleAdmin(FINANCIAL_ROLE, FINANCIAL_ADMIN_ROLE);
        _setRoleAdmin(WHITELISTED_MEMBER, WHITELIST_ROLE);
        _setRoleAdmin(WHITELIST_ROLE, WHITELIST_ADMIN_ROLE);

        // Grant all to the sender (owner)
        bytes32[4] memory roles = [
            FINANCIAL_ADMIN_ROLE,
            FINANCIAL_ROLE,
            WHITELIST_ADMIN_ROLE,
            WHITELIST_ROLE
        ];
        for (uint256 i = 0; i < roles.length; i++) {
            _setupRole(roles[i], msg.sender);
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
        whenNotPaused
        mintAmountVerify(amount)
        paymentVerify(amount)
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

    modifier mintAmountVerify(uint256 amount) {
        require(amount > 0, "amount must be larger than 0.");
        require(amount <= MINT_AMOUNT_LIMIT, "Too much amount.");
        require(totalSupply() + amount <= MAX_SUPPLY, "Supply limit exceeded.");
        _;
    }

    modifier paymentVerify(uint256 amount) {
        // My NFT?
        if (msg.sender == owner()) _;
        // If the message sender is listed in whitelist, he can mint NFT for free!
        if (hasRole(WHITELISTED_MEMBER, msg.sender)) _;
        // Check the cost is paid.
        require(msg.value >= COST * amount, "Not have enough asset.");
        _;
    }
}
