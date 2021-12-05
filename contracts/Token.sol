// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Token is ERC20 {
  address public minter;

  event MinterChanged(address indexed from, address to);
  AggregatorV3Interface internal priceFeed;

  constructor() payable ERC20("AvacadeBL", "ABL") {
    minter = msg.sender;
    priceFeed = AggregatorV3Interface(0x5498BB86BC934c8D34FDA08E81D444153d0D06aD);
  }

  function getLatestPrice() public view returns (int) {
      (
          uint80 roundID, 
          int256 answer,
          uint startedAt,
          uint timeStamp,
          uint80 answeredInRound
      ) = priceFeed.latestRoundData();
      // If the round is not complete yet, timestamp is 0
      require(timeStamp > 0, "Round not complete");
      return answer;
  }

  function decimals() public view virtual override returns (uint8) {
        return 0;
    }

  function passMinterRole(address GameSaloon) public returns(bool) {
    require(msg.sender == minter, "Error, only owner can change pass minter role");
    minter = GameSaloon;
    emit MinterChanged(msg.sender, minter);
    return true;
  }

  function mint(address account, uint256 amount) public {
    require(msg.sender == minter, "Error, msg.sender does not have minter role");
		_mint(account, amount);
	}

  function transferToken(address sender, address receiver, uint256 amount) public{
    _transfer(sender, receiver, amount);
  }
}