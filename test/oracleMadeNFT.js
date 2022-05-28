const express = require('express')
const http = require('http')
const truffleAssert = require('truffle-assertions')
const Contract = artifacts.require('OracleMadeNFT')

const svgDataUri = async string => {
    const sha256 = async text => Array
        .from(new Uint8Array(crypto.subtle.digest('SHA-256', new TextEncoder(text))))
        .map(v => v.toString(16).padStart(2, '0'))
        .join('')

    // Random color from a string
    const hexColor = '#' + await sha256(string).substring.substring(0, 6)
    // Square SVG filled by the color
    const svg = `<svg width="100" height="100" xmlns="http://www.w3.org/2000/svg" version="1.1"><rect x="0" y="0" width="100" height="100" fill="${hexColor}"/></svg>`
    // Encode the SVG
    const base64 = Buffer.from(svg, 'utf-8').toString('base64')
    // As a Data URI
    return `data:image/svg+xml;base64,${base64}`
}

contract('OracleMadeNFT', accounts => {

    var listening

    before(() => {
        // server as a oracle
        const oracle = express()
        // declare APIs
        oracle.get('/mint/:tokenId', async (request, response) => {
            const tokenId = request.params.tokenId
            console.log(`server is requested with tokenId: ${tokenId}`)
            response.json({
                uri: svgDataUri(tokenId),
                tokenId: tokenId,
            })
            response.end()
        })
        // start the server
        listening = http.createServer(oracle).listen(8888, () => {
            console.log('Oracle server is launched.')
        })
    })

    after(() => {
        listening.close(error => { console.log(error.message) })
    })

    it("Mint a NFT then receive a callback", async function () {
        const instance = await Contract.new()
        await instance.safeMint(accounts[1])
        // check __callback called

    })
})
