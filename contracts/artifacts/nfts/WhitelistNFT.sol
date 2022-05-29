// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract WhitelistNFT is ERC721 {
    using Counters for Counters.Counter;
    using MerkleProof for bytes32[];

    bytes32 public merkleRoot;
    Counters.Counter public counter;
    mapping(address => bool) public claimed;

    constructor(bytes32 _merkleRoot) ERC721("WhitelistNFT", "WHITE") {
        merkleRoot = _merkleRoot;
    }

    function mint(bytes32[] calldata merkleProof)
        public
        payable
        checkWhitelist(merkleProof)
        markAsDealt
    {
        counter.increment();
        _safeMint(msg.sender, counter.current());
    }

    modifier checkWhitelist(bytes32[] calldata merkleProof) {
        require(
            merkleProof.verify(
                merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "invalid merkle proof"
        );
        _;
    }

    modifier markAsDealt() {
        require(claimed[msg.sender] == false, "sender already claimed");
        _;
        claimed[msg.sender] = true;
    }
}
