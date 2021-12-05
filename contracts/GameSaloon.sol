// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./Token.sol";
import "./Game.sol";

contract GameSaloon {

    address owner;
    Token private _token;
    Game private _game;
    uint256 public mintFee;
    uint256 public rewardAmount;

    struct Place {
        bool isFull;
        uint gameId;
        address ownerAddress;
        uint endTime;
    }

    struct PlaceRents {
        uint id;
        uint rent;
    }

    mapping(uint256 => Place) public place;
    mapping(uint256 => uint256) public placeRent;
    mapping(uint256 => uint256) gameBank;

    event Rented(uint256 placeId, Place place);
    event RentTimeEnded(uint256 placeId, uint256 tokenTransferred);
    event Minted(uint256 tokenId, address tokenAddress);
    event TokenBuyed(uint256 tokenAmount, address tokenAddress);
    event UserRewarded(uint256 tokenAmount, address tokenAddress);

    constructor(Token token, Game game) {
        owner = msg.sender;
        _token = token;
        _game = game;
        mintFee = 1e16;
        rewardAmount = 5;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not authorized!");
        _;
    }
    
    function getLatestPrice() public view returns(int256) {
        return _token.getLatestPrice();
    }

    function getGameURI(uint256 gameId) public view returns(string memory){ 
        return _game.tokenURI(gameId);
    }

    function setMintFee(uint256 _mintFee) public onlyOwner{
        mintFee = _mintFee;
    }

    function setRewardAmount(uint256 _rewardAmount) public onlyOwner{
        rewardAmount = _rewardAmount;
    }
    
    function setRentPrice(PlaceRents[] memory placeRents) public onlyOwner {
        for(uint i=0; i<placeRents.length; i++) {
            placeRent[placeRents[i].id] = placeRents[i].rent;
        }
    }

    function mintGame(string memory tokenURI, address creator) public payable returns(uint256) {
        require(msg.value == mintFee, "You should send mint fee");
        uint256 itemId = _game.mint(tokenURI, creator);
        emit Minted(itemId, address(_game));
        return itemId;
    }

    function rentPlace(uint256 placeId, uint256 gameId, address ownerAddress) public payable {
        require(_game.ownerOf(gameId) == ownerAddress, "You are not the owner of this game!");
        Place storage placeToRent = place[placeId];
        require(placeRent[placeId] != 0, "Place is not rentable!");
        require(!placeToRent.isFull, "Place is full!");
        require(placeRent[placeId] == msg.value, "Rent amount is not enough!");

        placeToRent.isFull = true;
        placeToRent.gameId = gameId;
        placeToRent.ownerAddress = ownerAddress;
        placeToRent.endTime = block.timestamp + 60*60*24*30;

        emit Rented(placeId, placeToRent);
    }

    // We will require msg.value to be equal to latestPrice
    function buyToken(uint256 tokenAmount) public payable {
        _token.mint(msg.sender, tokenAmount);
        emit TokenBuyed(tokenAmount, address(_token));
    }

    function getUserBalance(address userAddress) public view returns(uint256) {
        return _token.balanceOf(userAddress);
    }

    function playGame(uint256 placeId) public {
        Place memory placeToPlay = place[placeId];
        require(placeToPlay.isFull, "Place is empty");
        _token.transferToken(msg.sender, address(this), 1);
        gameBank[placeToPlay.gameId] += 1;
    }

    function rewardUser(address userAddress) public onlyOwner {
        _token.mint(userAddress, rewardAmount);
        emit UserRewarded(rewardAmount, address(_token));
    }

    // will called by serverless timed function.
    function endRent(uint256  maxPlaceId) public onlyOwner {
        for(uint256 i=0; i<=maxPlaceId; i++) {
            Place memory placeRented = place[i];
            if(!placeRented.isFull){
                continue;
            }
            if(placeRented.endTime > block.timestamp){
                continue;
            }

            _token.transferToken(address(this), address(placeRented.ownerAddress), gameBank[i]);
            
            Place storage placeToModify = place[i];
            placeToModify.isFull = false;
            placeToModify.gameId = 0;
            placeToModify.ownerAddress = address(0);
            placeToModify.endTime = 0;

            emit RentTimeEnded(i, gameBank[i]);
            gameBank[i] = 0;
        }
    }
}