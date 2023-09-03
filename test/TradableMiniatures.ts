import { expect } from "chai";
import { ethers } from "hardhat";

describe("TradableMiniature", function() {
  async function deployContract() {
    const [owner, anotherUser] = await ethers.getSigners();

    const TradableMiniature = await ethers.getContractFactory("TradableMiniature");
    const tradableMiniature = await TradableMiniature.deploy();
    return { tradableMiniature, owner, anotherUser };
  }

  describe("Minting Miniature", async function() {
    it("Should mint a new miniature", async function() { 
      const { tradableMiniature, owner, anotherUser: minter } = await deployContract();
      const miniatureMetadata = {
        name: "Miniature",
        description: "A miniature",
        url: "https://example.com/image.png",
        price: 100
      }
      
      const connectedMinter = tradableMiniature.connect(minter);

      await connectedMinter.createMiniature(
        miniatureMetadata.name,
        miniatureMetadata.description,
        miniatureMetadata.url,
        miniatureMetadata.price
      )

      const ownedMiniatures = await connectedMinter.getOwnedMiniatures();
      expect(ownedMiniatures.length).to.equal(1);
      expect(ownedMiniatures[0].name).to.equal(miniatureMetadata.name);
    })
  })

  describe("Buying Miniature", async function() {
    it("Should buy a miniature", async function() {
      const { tradableMiniature, owner, anotherUser: minter } = await deployContract();
      const miniatureMetadata = {
        name: "Miniature",
        description: "A miniature",
        url: "https://example.com/image.png",
        price: 100
      }
      const connectedMinter = tradableMiniature.connect(owner);
      const connectedBuyer = tradableMiniature.connect(minter);
 
      await connectedMinter.createMiniature(
        miniatureMetadata.name,
        miniatureMetadata.description,
        miniatureMetadata.url,
        miniatureMetadata.price
      );

      const miniatureIndex = await connectedBuyer.getMiniatureIndex(1);
      await connectedBuyer.buyMiniature(miniatureIndex, { value: miniatureMetadata.price });

      const ownedMiniatures = await connectedBuyer.getOwnedMiniatures();
      expect(ownedMiniatures.length).to.equal(1);
      expect(ownedMiniatures[0].name).to.equal(miniatureMetadata.name);
    })
  })
  
})