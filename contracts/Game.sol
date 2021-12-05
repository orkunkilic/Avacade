// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Game is ERC721 {
   using Counters for Counters.Counter;
   Counters.Counter private _tokenIds;
   mapping(uint256 => string) tokenURIs;


  address public minter;
  event MinterChanged(address indexed from, address to);

   constructor() ERC721("AvacadeGame", "AG") {
         minter = msg.sender;
   }


   function mint(string memory tokenURI, address creator) public returns (uint256) {
       require(msg.sender == minter, "Error, msg.sender does not have minter role");
       _tokenIds.increment();
       uint256 newItemId = _tokenIds.current();
       _mint(creator, newItemId);
       setTokenURI(newItemId, tokenURI);
       return newItemId;
   }

   function setTokenURI(uint256 tokenId, string memory tokenUri) internal {
       require(keccak256(abi.encodePacked(tokenURIs[tokenId])) == keccak256(abi.encodePacked("")), "Cannot alter token URI");
       tokenURIs[tokenId] = tokenUri;
   }

   function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return tokenURIs[tokenId];
    }

    function passMinterRole(address GameSaloon) public returns(bool) {
        require(msg.sender == minter, "Error, only owner can change pass minter role");
        minter = GameSaloon;
        emit MinterChanged(msg.sender, GameSaloon);
        return true;
    }

}