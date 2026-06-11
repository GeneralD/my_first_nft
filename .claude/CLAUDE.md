# my_first_nft

Personal learning project (May 2022) for ERC-721 NFT smart contracts using
Truffle + OpenZeppelin. Legacy sample — not maintained, Truffle is sunset.

## Stack

- Solidity 0.8.13 (pragma `<0.9.0`), Truffle ^5.5.12, Yarn
- OpenZeppelin contracts 4.x (regular + upgradeable) and truffle-upgrades
- Tests: Truffle/mocha + truffle-assertions, eth-gas-reporter (currency JPY)
- Only network: `development` at 127.0.0.1:7545 (Ganache)

## Layout

- `contracts/artifacts/nfts/` — five contracts: InvitationMembershipNFT,
  LimitedInvitationMembershipNFT, WhitelistNFT (Merkle-proof gated mint),
  UpgradeableNFT_V1/V2 (proxy upgrade demo)
- `migrations/` — 5 deploy scripts incl. upgradeable deploy + V2 upgrade;
  whitelist root built with merkletreejs + keccak256
- `test/` — one suite per contract pattern

## Commands

`yarn install` → `truffle compile` / `truffle migrate` / `truffle test`
(requires a local Ganache node on port 7545).

Note: package.json declares MIT but there is no LICENSE file.
