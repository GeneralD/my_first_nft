// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NFT is Context, ERC721Enumerable {
    constructor(string memory name, string memory symbol)
        ERC721(name, symbol)
    {}

    function mint(address to) public virtual {
        // totalSupply works like auto incremented ID. It starts from 0.
        uint256 tokenId = totalSupply();
        _safeMint(to, tokenId, "");
    }
}
