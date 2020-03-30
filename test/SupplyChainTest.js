const SupplyChain = artifacts.require("SupplyChain");

contract("SupplyChain", accounts => {
  beforeEach(async () => {
    sku = 1;
    sellingPrice = 0;
    distributorSellingPrice = 0;
    purchasingPrice = 0;
    state = "0";
    productUpc = 1;
    farm = "Kigali Coffee Company South";
    organizationInfo = "Kigali Coffee Company Limited";
    latitude = "-1.9441";
    longitude = "30.0619";
    notes = "This is the first lot of the best quality harvest";
    owner = accounts[0];
    farmer = accounts[1];
    buyer = accounts[2];
    retailer = accounts[3];
    consumer = accounts[4];
    supplyChainContract = await SupplyChain.deployed();
  });

  describe("Farmer", () => {
    it("adds a new Farmer by the owner of the contract", async () => {
      await supplyChainContract.addFarmer(farmer, { from: owner });
      isFarmer = await supplyChainContract.isFarmer(farmer);
      assert.equal(isFarmer, true);
    });

    it("removes a Farmer from the Farmer's group by the farmer", async () => {
      await supplyChainContract.renounceFarmer({ from: farmer });
      isFarmer = await supplyChainContract.isFarmer(farmer);
      assert.equal(isFarmer, false);
    });

    it("Farmer can harvest coffee", async () => {
      await supplyChainContract.addFarmer(farmer, { from: owner });
      await supplyChainContract.harvestCoffee(
        productUpc,
        farm,
        organizationInfo,
        longitude,
        latitude,
        notes,
        farmer,
        { from: farmer }
      );
      coffeeLot = await supplyChainContract.trackCoffeeBufferOne(sku, {
        from: farmer
      });
      assert.equal(coffeeLot.stateIs, "Harvested");
    });

    it("Farmer can process coffee", async () => {
      await supplyChainContract.processCoffee(sku, { from: farmer });
      coffeeLot = await supplyChainContract.trackCoffeeBufferOne(sku, {
        from: farmer
      });
      assert.equal(coffeeLot.stateIs, "Processed");
    });

    it("Farmer can pack coffee", async () => {
      await supplyChainContract.packCoffee(sku, { from: farmer });
      coffeeLot = await supplyChainContract.trackCoffeeBufferOne(sku, {
        from: farmer
      });
      assert.equal(coffeeLot.stateIs, "Packed");
    });

    it("Farmer can advertise coffee", async () => {
      sellingPrice = 10;
      await supplyChainContract.advertiseCoffee(sku, sellingPrice, {
        from: farmer
      });
      coffeeLot = await supplyChainContract.trackCoffeeBufferOne(sku, {
        from: farmer
      });
      assert.equal(coffeeLot.sellingPrice, 10);
      assert.equal(coffeeLot.stateIs, "Advertised");
    });
  });
});

describe("Distributor", () => {
  it("adds a new Distributor by the owner of the contract", async () => {
    await supplyChainContract.addDistributor(buyer, { from: owner });
    isDistributor = await supplyChainContract.isDistributor(buyer);
    assert.equal(isDistributor, true);
  });

  it("removes a Distributor from the Distributor's group by the distributor", async () => {
    await supplyChainContract.renounceDistributor({ from: buyer });
    isDistributor = await supplyChainContract.isDistributor(buyer);
    assert.equal(isDistributor, false);
  });

  it("Distributor can buy coffee from Farmer", async () => {
    await supplyChainContract.addDistributor(buyer, { from: owner });
    distributorSellingPrice = 15;
    coffeeLot = await supplyChainContract.trackCoffeeBufferOne(sku, {
      from: buyer
    });
    await supplyChainContract.buyCoffee(sku, distributorSellingPrice, {
      from: buyer,
      value: coffeeLot.sellingPrice
    });
    coffeeLot = await supplyChainContract.trackCoffeeBufferOne(sku, {
      from: buyer
    });
    assert.equal(coffeeLot.purchasingPrice, 15);
    assert.equal(coffeeLot.stateIs, "Bought");
  });
});

describe("Farmer", () => {
  it("adds a new Retailer by the owner of the contract", async () => {
    await supplyChainContract.addRetailer(retailer, { from: owner });
    isRetailer = await supplyChainContract.isRetailer(retailer);
    assert.equal(isRetailer, true);
  });

  it("removes a Retailer from the Retailer's group by the Retailer", async () => {
    await supplyChainContract.renounceRetailer({ from: retailer });
    isRetailer = await supplyChainContract.isRetailer(retailer);
    assert.equal(isRetailer, false);
  });

  it("Farmer can ship coffee to retailer", async () => {
    await supplyChainContract.shipCoffee(sku, { from: farmer });
    coffeeLot = await supplyChainContract.trackCoffeeBufferOne(sku, {
      from: farmer
    });
    assert.equal(coffeeLot.stateIs, "Shipped");
  });
});

describe("Retailer", () => {
  it("Retailer can receive coffee from farmer", async () => {
    await supplyChainContract.addRetailer(retailer, { from: owner });
    await supplyChainContract.receiveCoffee(sku, { from: retailer });
    coffeeLot = await supplyChainContract.trackCoffeeBufferOne(sku, {
      from: retailer
    });
    assert.equal(coffeeLot.stateIs, "Received");
  });
});

describe("Consumer", () => {
  it("adds a new consumer by the owner of the contract", async () => {
    await supplyChainContract.addConsumer(consumer, { from: owner });
    isConsumer = await supplyChainContract.isConsumer(consumer);
    assert.equal(isConsumer, true);
  });

  it("removes a Consumer from the Consumer's group by the Consumer", async () => {
    await supplyChainContract.renounceConsumer({ from: consumer });
    isConsumer = await supplyChainContract.isConsumer(consumer);
    assert.equal(isConsumer, false);
  });

  it("Consumer can purchase coffee from Distributor", async () => {
    await supplyChainContract.addConsumer(consumer, { from: owner });
    coffeeLot = await supplyChainContract.trackCoffeeBufferOne(sku, {
      from: consumer
    });
    await supplyChainContract.purchaseCoffee(sku, {
      from: consumer,
      value: coffeeLot.purchasingPrice
    });
    coffeeLot = await supplyChainContract.trackCoffeeBufferOne(sku, {
      from: consumer
    });
    assert.equal(coffeeLot.stateIs, "Purchased");
  });
});

describe("Tracking", () => {
  it("can track the coffee with the first set of information", async () => {
    coffeeLot = await supplyChainContract.trackCoffeeBufferOne(sku, {
      from: farmer
    });
    assert.equal(coffeeLot.sku, sku);
    assert.equal(coffeeLot.sellingPrice, 10);
    assert.equal(coffeeLot.purchasingPrice, 15);
    assert.equal(coffeeLot.stateIs, "Purchased");
    assert.equal(coffeeLot.productUpc, productUpc);
    assert.equal(coffeeLot.farm, farm);
    assert.equal(coffeeLot.organizationInfo, organizationInfo);
  });

  it("can track the coffee with the second set of information", async () => {
    coffeeLot = await supplyChainContract.trackCoffeeBufferTwo(sku, {
      from: farmer
    });
    assert.equal(coffeeLot.sku, sku);
    assert.equal(coffeeLot.lat, latitude);
    assert.equal(coffeeLot.long, longitude);
    assert.equal(coffeeLot.farmer, farmer);
    assert.equal(coffeeLot.buyer, buyer);
    assert.equal(coffeeLot.retailer, retailer);
    assert.equal(coffeeLot.consumer, consumer);
  });
});
