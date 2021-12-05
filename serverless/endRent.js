require('dotenv').config();
const Web3 = require('web3');
const Tx = require('ethereumjs-tx').Transaction;
var Common = require('ethereumjs-common').default;
const GameSaloon = require('./GameSaloon.json');

exports.handler = async function (event, context) {
  const web3 = new Web3('https://api.avax-test.network/ext/bc/C/rpc');
  var FUJI = Common.forCustomChain(
    'mainnet',
    {
      name: 'Avalanche FUJI C-Chain',
      networkId: 43113,
      chainId: 43113,
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
    },
    'istanbul'
  );
  const gameSaloon = new web3.eth.Contract(GameSaloon.abi, GameSaloon.address);
  const txn = await gameSaloon.methods.endRent(event.placeId);
  const gas = await txn.estimateGas({
    from: process.env.ownerAdress,
  });
  const gasPrice = await web3.eth.getGasPrice();
  const data = txn.encodeABI();
  const nonce = await web3.eth.getTransactionCount(process.env.ownerAdress);
  const rawTx = {
    to: GameSaloon.address,
    from: process.env.ownerAdress,
    data: data,
    gasLimit: web3.utils.toHex(gas),
    gasPrice: web3.utils.toHex(gasPrice),
    nonce: web3.utils.toHex(nonce),
    chainId: await web3.eth.net.getId(),
  };
  const tx = new Tx(rawTx, { common: FUJI });
  const privateKey1Buffer = Buffer.from(process.env.ownerPK, 'hex');
  tx.sign(privateKey1Buffer);
  var serializedTx = tx.serialize();

  web3.eth
    .sendSignedTransaction('0x' + serializedTx.toString('hex'))
    .then((res) => console.log(res));
};
