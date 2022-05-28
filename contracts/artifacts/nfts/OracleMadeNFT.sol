// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "../provable/provableAPI_0.8.sol";

contract OracleMadeNFT is ERC721, ERC721URIStorage, Ownable, usingProvable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping(bytes32 => uint256) private tokenIdByQueryId;

    constructor() ERC721("OracledNFT", "ORCL") {}

    function safeMint(address to) external payable onlyOwner checkBalance {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        bytes32 id = provable_query(
            "URL",
            string(
                abi.encodePacked(
                    "json(http://localhost:8888/mint/",
                    tokenId,
                    ").uri"
                )
            )
        );
        tokenIdByQueryId[id] = tokenId;
    }

    function __callback(bytes32 myId, string memory result)
        public
        override
        checkCallbackAddress
    {
        uint256 tokenId = tokenIdByQueryId[myId];
        require(tokenId > 0);
        _setTokenURI(tokenId, result);
    }

    // The following functions are overrides required by Solidity.

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    modifier checkBalance() {
        require(
            address(this).balance >= provable_getPrice("URL"),
            "Add some ETH to cover for the query fee!"
        );
        _;
    }

    modifier checkCallbackAddress() {
        require(
            msg.sender == provable_cbAddress(),
            "Callback doesn't want to be invoked by stranger address!"
        );
        _;
    }
}
