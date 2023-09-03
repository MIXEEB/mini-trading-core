// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
//import erc721 
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

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
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;
  Miniature[] public miniatures; 

  constructor() ERC721("TradableMiniature", "TDMT") {
    _tokenIds.increment();
  }

  function createMiniature(string memory _name, string memory _description, string memory _url, uint256 _price) public returns(uint256) {
    uint newId = _tokenIds.current();
    Miniature memory newMiniature = Miniature(_name, _description, _url, _price, newId, msg.sender);
    miniatures.push(newMiniature);
    _safeMint(msg.sender, miniatures.length);
    _tokenIds.increment();
    return newId;
  }

  function buyMiniature(uint256 _index) public payable {
    Miniature memory miniature = miniatures[_index];
    require(msg.value == miniature.price, "Price not met");
    require(msg.value >= miniature.price, "Not enough funds sent");
    require(miniature.owner != msg.sender, "You already own this miniature");
    payable(miniature.owner).transfer(msg.value);
    _transfer(miniature.owner, msg.sender, miniature.id);
    miniature.owner = msg.sender;
    miniatures[_index] = miniature;
  }

  function getAllMiniatures() public view returns (Miniature[] memory) {
    return miniatures;
  }

  function getMiniatureIndex(uint256 _id) public view returns (uint256) {
    for(uint256 i = 0; i < miniatures.length; i++) {
      if(miniatures[i].id == _id) {
        return i;
      }
    }
    revert("Miniature not found");
  }

  function getOwnedMiniatures() public view returns (Miniature[] memory) {
    Miniature[] memory ownedMiniatures = new Miniature[](balanceOf(msg.sender));
    uint256 index = 0;
    for (uint256 i = 0; i < miniatures.length; i++) {
        if (miniatures[i].owner == msg.sender) {
            ownedMiniatures[index] = miniatures[i];
            index++;
        }
    }

    return ownedMiniatures;
  }

}