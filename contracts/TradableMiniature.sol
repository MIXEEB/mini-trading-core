// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
//import erc721 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Smart contract for a tradable miniature NTF
struct  Miniature {
  string name;
  string description;
  string url;
  uint256 price;
  uint256 id;
  address owner;
}

contract TradableMiniature is ERC721 {

  // Array of all the miniatures
  Miniature[] public miniatures;
  mapping(address => Miniature[]) public miniaturesByOwner;

  constructor() ERC721("TradableMiniature", "TDMT") {
  }

  function createMiniature(string memory _name, string memory _description, string memory _url, uint256 _price) public {
    Miniature memory newMiniature = Miniature(_name, _description, _url, _price, miniatures.length, msg.sender);
    miniatures.push(newMiniature);
    miniaturesByOwner[msg.sender].push(newMiniature);
    _safeMint(msg.sender, miniatures.length);
  }

  function getAllMiniatures() public view returns (Miniature[] memory) {
    return miniatures;
  }

  function getOwnedMiniatures() public view returns (Miniature[] memory) {
    return miniaturesByOwner[msg.sender];
  }

}