import Web3 from 'web3'

import detectEthereumProvider from '@metamask/detect-provider'

import SmartContract from '../../artifacts/NFT.json'

export async function connectBlockchain() {
    const ethereumProvider = await detectEthereumProvider({ mustBeMetaMask: true }) as any
    if (!ethereumProvider) throw 'No ethereum platform or MetaMask is not installed.'

    const web3 = new Web3(ethereumProvider)
    web3.eth.setProvider(ethereumProvider)

    if (await web3.eth.getChainId() != 137) throw 'Switch network to Polygon.'

    const accounts = await web3.eth.requestAccounts()
    const contract = new web3.eth.Contract(SmartContract.abi as any, "")

    return {
        web3: web3,
        account: accounts[0],
        smartContract: contract,
    }
}