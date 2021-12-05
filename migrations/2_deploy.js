const Token = artifacts.require('Token');
const Game = artifacts.require('Game');
const GameSaloon = artifacts.require('GameSaloon');

module.exports = async function (deployer) {
  await deployer.deploy(Token);
  const token = await Token.deployed();

  await deployer.deploy(Game);
  const game = await Game.deployed();

  await deployer.deploy(GameSaloon, token.address, game.address);
  const gameSaloon = await GameSaloon.deployed();

  await token.passMinterRole(gameSaloon.address);
  await game.passMinterRole(gameSaloon.address);
};
