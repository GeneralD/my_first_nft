module.exports = {
  compilers: {
    solc: {
      version: "0.8.13",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        },
      }
    }
  },
  contracts_build_directory: "./src/artifacts/", // to use ABI in frontend (react)
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*",
      gas: 5_000_000
    }
  }
}
