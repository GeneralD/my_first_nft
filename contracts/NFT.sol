// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/// @author Yumenosuke Kokata
/// @title A simple NFT
contract NFT is Context, ERC721Enumerable, Ownable {
    bool public isPaused = false;
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

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    // Public Members

    function mint(address to) public virtual {
        mint(to, 1);
    }

    function mint(address to, uint256 amount)
        public
        payable
        virtual
        mintVerify(amount)
        whitelistVerify(amount)
    {
        // totalSupply works like auto incremented ID. It starts from 0.
        uint256 startTokenId = totalSupply();

        for (uint256 i = 0; i < amount; i++) {
            uint256 tokenId = startTokenId + i;
            _safeMint(to, tokenId);
        }
    }

    function withdraw() public payable onlyOwner {
        require(payable(msg.sender).send(address(this).balance));
    }

    // Setters

    function pause(bool _isPaused) public onlyOwner {
        isPaused = _isPaused;
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
        require(!isPaused, "Minting is held.");
        require(amount > 0, "amount must be larger than 0.");
        require(amount <= mintAmountLimit, "Too much amount.");
        require(totalSupply() + amount <= maxSupply, "Supply limit exceeded.");
        _;
    }

    modifier whitelistVerify(uint256 amount) {
        if (msg.sender == owner()) _;
        if (whitelisted[msg.sender]) _;
        require(msg.value >= cost * amount, "Not have enough asset.");
        _;
    }
}