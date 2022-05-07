// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";

/// @author Yumenosuke Kokata
/// @title A simple NFT
contract NFT is
    AccessControl,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable
{
    using Strings for uint256;

    bytes32 public constant MINTER_ADMIN_ROLE = keccak256("MINTER_ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    bytes32 public constant BURNER_ADMIN_ROLE = keccak256("BURNER_ADMIN_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    bytes32 public constant CONFIG_ADMIN_ROLE = keccak256("CONFIG_ADMIN_ROLE");
    bytes32 public constant CONFIG_ROLE = keccak256(("CONFIG_ROLE"));

    bytes32 public constant FINANCIAL_ROLE = keccak256("FINANCIAL_ROLE");
    bytes32 public constant FINANCIAL_ADMIN_ROLE =
        keccak256("FINANCIAL_ADMIN_ROLE");

    bytes32 public constant WHITELIST_ADMIN_ROLE =
        keccak256("WHITELIST_ADMIN_ROLE");
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");
    bytes32 public constant WHITELISTED_MEMBER =
        keccak256("WHITELISTED_MEMBER");

    uint256 public cost = 10 ether;
    string public baseURI;
    string public baseExtension = ".json";
    uint256 public mintAmountLimit = 40;
    uint256 public maxSupply = 1_000;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        // Granter roles
        _setRoleAdmin(MINTER_ROLE, MINTER_ADMIN_ROLE);
        _setRoleAdmin(BURNER_ROLE, BURNER_ADMIN_ROLE);
        _setRoleAdmin(CONFIG_ROLE, CONFIG_ADMIN_ROLE);
        _setRoleAdmin(FINANCIAL_ROLE, FINANCIAL_ADMIN_ROLE);
        _setRoleAdmin(WHITELISTED_MEMBER, WHITELIST_ROLE);
        _setRoleAdmin(WHITELIST_ROLE, WHITELIST_ADMIN_ROLE);

        // Grant all to the sender (owner)
        bytes32[10] memory roles = [
            MINTER_ADMIN_ROLE,
            MINTER_ROLE,
            BURNER_ADMIN_ROLE,
            BURNER_ROLE,
            CONFIG_ADMIN_ROLE,
            CONFIG_ROLE,
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
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Token doesn't exist.");

        return
            bytes(baseURI).length > 0
                ? string( // e.g. https://baseurl/123.json
                    abi.encodePacked(baseURI, tokenId.toString(), baseExtension)
                )
                : "";
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

    function burn(uint256 tokenId)
        public
        virtual
        override
        whenNotPaused
        onlyRole(BURNER_ROLE)
    {
        return super.burn(tokenId);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721Pausable, ERC721Enumerable, ERC721) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // Public Members

    function mint(address to) public virtual {
        mint(to, 1);
    }

    function mint(address to, uint256 amount)
        public
        payable
        virtual
        whenNotPaused
        onlyRole(MINTER_ROLE)
        mintAmountVerify(amount)
        paymentVerify(amount)
    {
        // totalSupply works like auto incremented ID. It starts from 0.
        uint256 startTokenId = totalSupply();

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = startTokenId + i;
            _safeMint(to, tokenId);
        }
    }

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

    // Only owner can change the configurations

    function pause(bool status) public onlyRole(CONFIG_ROLE) {
        if (status) _pause();
        else _unpause();
    }

    function setCost(uint256 _cost) public onlyRole(CONFIG_ROLE) {
        cost = _cost;
    }

    function setMintAmountLimit(uint256 _limit) public onlyRole(CONFIG_ROLE) {
        mintAmountLimit = _limit;
    }

    function setBaseURI(string memory _uri) public onlyRole(CONFIG_ROLE) {
        baseURI = _uri;
    }

    function setBaseExtension(string memory _extension)
        public
        onlyRole(CONFIG_ROLE)
    {
        baseExtension = _extension;
    }

    // Modifiers

    modifier mintAmountVerify(uint256 amount) {
        require(amount > 0, "amount must be larger than 0.");
        require(amount <= mintAmountLimit, "Too much amount.");
        require(totalSupply() + amount <= maxSupply, "Supply limit exceeded.");
        _;
    }

    modifier paymentVerify(uint256 amount) {
        // My NFT?
        // if (msg.sender == owner()) _;
        // If the message sender is listed in whitelist, he can mint NFT for free!
        if (hasRole(WHITELISTED_MEMBER, msg.sender)) _;
        // Check the cost is paid.
        require(msg.value >= cost * amount, "Not have enough asset.");
        _;
    }
}
