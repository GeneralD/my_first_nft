// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "solidity-stringutils/strings.sol";
import "../utils/provableAPI_0.8.sol";
import "../utils/StringUtils.sol";

contract OracleMadeNFT is ERC721, ERC721URIStorage, Ownable, usingProvable {
    using Counters for Counters.Counter;
    using strings for *;
    using StringUtils for string;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("OracledNFT", "ORCL") {}

    function safeMint(address to) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);

        provable_query(
            "URL",
            string(
                abi.encodePacked(
                    "json(http://localhost:8888/mint/",
                    tokenId,
                    ").[tokenId,uri]"
                )
            )
        );
    }

    function __callback(bytes32 myId, string memory result) public override {
        if (msg.sender != provable_cbAddress()) revert();
        strings.slice memory slices = result.toSlice();
        strings.slice memory delimiter = ",".toSlice();
        string[] memory parts = new string[](slices.count(delimiter) + 1);
        for (uint256 i = 0; i < parts.length; i++)
            parts[i] = slices.split(delimiter).toString();

        uint256 tokenId = parts[0]
            .substring(2, parts[0].toSlice().len() - 1)
            .toInt();
        string memory uri = parts[1].substring(1, parts[1].toSlice().len() - 2);

        _setTokenURI(tokenId, uri);
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
}
