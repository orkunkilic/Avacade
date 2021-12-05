require('babel-register');
require('babel-polyfill');
require('dotenv').config();
const HDWalletProvider = require('@truffle/hdwallet-provider');
const privateKeys = process.env.PRIVATE_KEYS || '';

module.exports = {
  networks: {
    avax: {
      provider: function () {
        return new HDWalletProvider(
          privateKeys.split(','), // Array of account private keys
          `https://api.avax-test.network/ext/bc/C/rpc` // Url to an Ethereum Node
        );
      },
      network_id: '*',
      gas: 3000000,
      gasPrice: 225000000000,
    },
  },
  contracts_directory: './contracts/',
  contracts_build_directory: './contracts/abis/',
  compilers: {
    solc: {
      version: '>=0.7.0 <0.9.0',
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
