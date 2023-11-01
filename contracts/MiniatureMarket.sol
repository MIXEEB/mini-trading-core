// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TradableMiniature.sol";

contract MiniatureMarket {
  TradableMiniature internal tradableMiniature;

  struct Offer {
    uint256 id;
    uint256 price;
    address seller;
    address buyer;
    uint256 miniatureId;
    bytes32 key;
    bool active;
    bool frozen;
  }

  Offer[] public offers;
  mapping(uint256 => Offer) public miniatureIdToOffer;

  mapping(uint256 => uint256) private frozenOffers;

  constructor(address _tradableMiniatureAddress) {
    tradableMiniature = TradableMiniature(_tradableMiniatureAddress);
  }

  function placeOffer(uint256 _miniatureId, uint256 _price, string memory key) public {
    require(tradableMiniature.ownerOf(_miniatureId) == msg.sender, "Only the owner can place an offer");
    require(tradableMiniature.getApproved(_miniatureId) == address(this), "The contract is not approved to manage this miniature");
    require(_price > 0, "Price must be greater than 0");

    bytes32 keyHash = keccak256(bytes(key));
    Offer memory newOffer = Offer(offers.length, _price, msg.sender, address(0), _miniatureId, keyHash, true, false);
    offers.push(newOffer);
    miniatureIdToOffer[_miniatureId] = newOffer;
  }

  function acceptOffer(uint256 _offerId) public payable {
    Offer storage offer = offers[_offerId];
    require(offer.active, "Offer is not active");
    require(msg.sender != offer.seller, "Seller cannot accept their own offer");
    require(msg.value == offer.price, "Incorrect payment amount");

    offer.buyer = msg.sender;
    offer.active = false;
    offer.frozen = true;
    frozenOffers[offer.id] = msg.value;
    tradableMiniature.transferFrom(offer.seller, msg.sender, offer.miniatureId);
  }

  function verifyOffer(uint _offerId, string memory key) public {
    Offer storage offer = offers[_offerId];

    require(offer.frozen, "Offer is not frozen");
    require(offer.buyer == msg.sender, "Only the buyer can verify the offer");
    require(offer.key == keccak256(bytes(key)), "Incorrect key");

    offer.frozen = false;
    payable(offer.seller).transfer(frozenOffers[offer.id]);

  }

}
