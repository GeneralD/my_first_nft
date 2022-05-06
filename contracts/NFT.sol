// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";

/// @author Yumenosuke Kokata
/// @title A simple NFT
contract NFT is Ownable, ERC721Enumerable, ERC721Burnable, ERC721Pausable {
    using Strings for uint256;

    uint256 public cost = 10 ether;
    string public baseURI;
    string public baseExtension = ".json";
    uint256 public mintAmountLimit = 40;
    uint256 public maxSupply = 1_000;

    mapping(address => bool) public whitelisted;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

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
        override(ERC721Enumerable, ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function burn(uint256 tokenId) public virtual override whenPaused {
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
        whenPaused
        mintVerify(amount)
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

    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    // Only owner can change the configurations

    function pause(bool status) public onlyOwner {
        if (status) _pause();
        else _unpause();
    }

    function setCost(uint256 _cost) public onlyOwner {
        cost = _cost;
    }

    function setMintAmountLimit(uint256 _limit) public onlyOwner {
        mintAmountLimit = _limit;
    }

    function setBaseURI(string memory _uri) public onlyOwner {
        baseURI = _uri;
    }

    function setBaseExtension(string memory _extension) public onlyOwner {
        baseExtension = _extension;
    }

    function addWhitelistedUser(address _user) public onlyOwner {
        whitelisted[_user] = true;
    }

    function removeWhitelistedUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }

    // Modifiers

    modifier mintVerify(uint256 amount) {
        require(amount > 0, "amount must be larger than 0.");
        require(amount <= mintAmountLimit, "Too much amount.");
        require(totalSupply() + amount <= maxSupply, "Supply limit exceeded.");
        _;
    }

    modifier paymentVerify(uint256 amount) {
        // My NFT?
        if (msg.sender == owner()) _;
        // If the message sender is listed in whitelist, he can mint NFT for free!
        if (whitelisted[msg.sender]) _;
        // Check the cost is paid.
        require(msg.value >= cost * amount, "Not have enough asset.");
        _;
    }
}
