const truffleAssert = require('truffle-assertions')
const keccak256 = require('keccak256')
const { MerkleTree } = require('merkletreejs')
const Contract = artifacts.require('WhitelistNFT')

contract('WhitelistNFT', accounts => {

    const whitelisted = accounts.filter((_, index) => index % 2 == 0)
    const notWhitelisted = accounts.filter((_, index) => index % 2 == 1)

    const leaves = whitelisted.map(account => keccak256(account))
    const tree = new MerkleTree(leaves, keccak256, { sort: true })
    const root = tree.getHexRoot()

    it('Test merkletree', () => {
        const target = keccak256(whitelisted[0])
        assert.ok(tree.verify(tree.getHexProof(target), target, root))
    })

    it('Whitelisted accounts can mint a NFT', async () => {
        const instance = await Contract.new(root)

        describe('Test whitelisted accounts', async () => {
            for (let index = 0; index < whitelisted.length; index++) {
                const account = whitelisted[index]

                it(`Account: ${account}`, async () => {
                    const proof = tree.getHexProof(keccak256(account))
                    // whitelisted account tries to mint
                    await instance.mint(proof, { from: account })
                    // minting is allowed only once per user
                    await truffleAssert.fails(instance.mint(proof, { from: account }))
                })
            }
        })
    })

    it('Accounts not in whitelist can not mint NFT', async () => {
        const instance = await Contract.new(root)

        describe('Test accounts not in whitelist', async () => {
            for (let index = 0; index < notWhitelisted.length; index++) {
                const account = notWhitelisted[index]

                it(`Account: ${account}`, async () => {
                    const proof = tree.getHexProof(keccak256(account))
                    await truffleAssert.fails(instance.mint(proof, { from: account }))
                })
            }
        })
    })
})