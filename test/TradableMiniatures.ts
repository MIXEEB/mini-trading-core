import { expect } from "chai";
import { ethers } from "hardhat";

describe("TradableMiniature", function() {
  async function deployContract() {
    const [owner, anotherAddress] = await ethers.getSigners();

    const TradableMiniature = await ethers.getContractFactory("TradableMiniature");
    const tradableMiniature = await TradableMiniature.deploy();
    return { tradableMiniature, owner, anotherAddress };
  }

  describe("Minting Miniature", async function() {
    it("Should mint a new miniature", async function() { 
      const { tradableMiniature, owner, anotherAddress: minter } = await deployContract();
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
  
})