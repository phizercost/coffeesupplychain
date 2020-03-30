App = {
  web3Provider: null,
  contracts: {},
  emptyAddress: "0x0000000000000000000000000000000000000000",
  sku: 0,
  upc: 0,
  metamaskAccountID: "0x0000000000000000000000000000000000000000",
  addressID: "0x0000000000000000000000000000000000000000",
  originFarmerID: "0x0000000000000000000000000000000000000000",
  originFarmName: null,
  originFarmInformation: null,
  originFarmLatitude: null,
  originFarmLongitude: null,
  productNotes: null,
  productPrice: 0,
  distributorID: "0x0000000000000000000000000000000000000000",
  retailerID: "0x0000000000000000000000000000000000000000",
  consumerID: "0x0000000000000000000000000000000000000000",

  init: async function() {
    App.readForm();
    /// Setup access to blockchain
    return await App.initWeb3();
  },

  readForm: function() {
    //App.sku = $("#sku").val();
    App.upc = $("#upc").val();
    App.addressID = $("#addressID").val();
    //App.originFarmerID = $("#originFarmerID").val();
    App.originFarmName = $("#originFarmName").val();
    App.originFarmInformation = $("#originFarmInformation").val();
    App.originFarmLatitude = $("#originFarmLatitude").val();
    App.originFarmLongitude = $("#originFarmLongitude").val();
    App.productNotes = $("#productNotes").val();
    App.productPrice = $("#productPrice").val();
    //App.distributorID = $("#distributorID").val();
    //App.retailerID = $("#retailerID").val();
    //App.consumerID = $("#consumerID").val();

    console.log(
      //App.sku,
      App.upc,
      App.addressID,
      //App.originFarmerID,
      App.originFarmName,
      App.originFarmInformation,
      App.originFarmLatitude,
      App.originFarmLongitude,
      App.productNotes,
      App.productPrice
      //App.distributorID,
      //App.retailerID,
      //App.consumerID
    );
  },

  initWeb3: async function() {
    /// Find or Inject Web3 Provider
    /// Modern dapp browsers...
    if (window.ethereum) {
      App.web3Provider = window.ethereum;
      try {
        // Request account access
        await window.ethereum.enable();
      } catch (error) {
        // User denied account access...
        console.error("User denied account access");
      }
    }
    // Legacy dapp browsers...
    else if (window.web3) {
      App.web3Provider = window.web3.currentProvider;
    }
    // If no injected web3 instance is detected, fall back to Ganache
    else {
      App.web3Provider = new Web3.providers.HttpProvider(
        "http://localhost:7545"
      );
    }

    App.getMetaskAccountID();

    return App.initSupplyChain();
  },

  getMetaskAccountID: function() {
    web3 = new Web3(App.web3Provider);

    // Retrieving accounts
    web3.eth.getAccounts(function(err, res) {
      if (err) {
        console.log("Error:", err);
        return;
      }
      console.log("getMetaskID:", res);
      App.metamaskAccountID = res[0];
    });
  },

  initSupplyChain: function() {
    /// Source the truffle compiled smart contracts
    var jsonSupplyChain = "../../build/contracts/SupplyChain.json";

    /// JSONfy the smart contracts
    $.getJSON(jsonSupplyChain, function(data) {
      console.log("data", data);
      var SupplyChainArtifact = data;
      App.contracts.SupplyChain = TruffleContract(SupplyChainArtifact);
      App.contracts.SupplyChain.setProvider(App.web3Provider);

      App.fetchEvents();
    });

    return App.bindEvents();
  },

  bindEvents: function() {
    $(document).on("click", App.handleButtonClick);
  },

  handleButtonClick: async function(event) {
    event.preventDefault();
    document.getElementById("trackone").style.display = "none";
    document.getElementById("tracktwo").style.display = "none";
    App.getMetaskAccountID();
    App.readForm();

    var processId = parseInt($(event.target).data("id"));
    console.log("processId", processId);

    switch (processId) {
      case 1:
        return await App.addFarmer(event);
        break;
      case 2:
        return await App.addDistributor(event);
        break;
      case 3:
        return await App.addRetailer(event);
        break;
      case 4:
        return await App.addConsumer(event);
        break;
      case 5:
        return await App.harvestCoffee(event);
        break;
      case 6:
        return await App.processCoffee(event);
        break;
      case 7:
        return await App.packCoffee(event);
        break;
      case 8:
        return await App.trackCoffeeBufferOne(event);
        break;
      case 9:
        return await App.trackCoffeeBufferTwo(event);
        break;
      case 10:
        return await App.advertiseCoffee(event);
        break;
      case 11:
        return await App.buyCoffee(event);
        break;
      case 12:
        return await App.shipCoffee(event);
        break;
      case 13:
        return await App.receiveCoffee(event);
        break;
      case 14:
        return await App.purchaseCoffee(event);
        break;
    }
  },

  addFarmer: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));
    try {
      const contract = await App.contracts.SupplyChain.deployed();
      const result = await contract.addFarmer(App.addressID, {
        from: App.metamaskAccountID
      });
      $("#ftc-item").text(result);
      console.log("addFarmer", result);
    } catch (error) {
      console.error(error.message);
    }
  },

  addDistributor: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));
    try {
      const contract = await App.contracts.SupplyChain.deployed();
      const result = await contract.addDistributor(App.addressID, {
        from: App.metamaskAccountID
      });
      $("#ftc-item").text(result);
      console.log("addDistributor", result);
    } catch (error) {
      console.error(error.message);
    }
  },

  addRetailer: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));
    try {
      const contract = await App.contracts.SupplyChain.deployed();
      const result = await contract.addRetailer(App.addressID, {
        from: App.metamaskAccountID
      });
      $("#ftc-item").text(result);
      console.log("addRetailer", result);
    } catch (error) {
      console.error(error.message);
    }
  },

  addConsumer: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));
    try {
      const contract = await App.contracts.SupplyChain.deployed();
      const result = await contract.addConsumer(App.addressID, {
        from: App.metamaskAccountID
      });
      $("#ftc-item").text(result);
      console.log("addConsumer", result);
    } catch (error) {
      console.error(error.message);
    }
  },

  advertiseCoffee: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));
    try {
      const contract = await App.contracts.SupplyChain.deployed();
      const productPrice = web3.toWei(App.productPrice, "ether");
      const result = await contract.advertiseCoffee(App.upc, productPrice, {
        from: App.metamaskAccountID
      });
      $("#ftc-item").text(result);
      console.log("advertiseCoffee", result);
    } catch (error) {
      console.error(error.message);
    }
  },

  harvestCoffee: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));
    try {
      const contract = await App.contracts.SupplyChain.deployed();
      const result = await contract.harvestCoffee(
        App.upc,
        App.originFarmName,
        App.originFarmInformation,
        App.originFarmLongitude,
        App.originFarmLatitude,
        App.productNotes,
        App.metamaskAccountID,
        { from: App.metamaskAccountID }
      );
      console.log("harvestCoffee", result);
    } catch (error) {
      console.error(error.message);
    }
  },

  processCoffee: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));
    try {
      const contract = await App.contracts.SupplyChain.deployed();
      const result = await contract.processCoffee(App.upc, {
        from: App.metamaskAccountID
      });
      console.log("processCoffee", result);
    } catch (error) {
      console.log(error.message);
    }
  },

  packCoffee: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));
    try {
      const contract = await App.contracts.SupplyChain.deployed();
      const result = await contract.packCoffee(App.upc, {
        from: App.metamaskAccountID
      });
      console.log("packCoffee", result);
    } catch (error) {
      console.log(error.message);
    }
  },

  buyCoffee: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));

    try {
      const contract = await App.contracts.SupplyChain.deployed();

      const walletValue = web3.toWei(App.productPrice, "ether");
      const result = await contract
        .buyCoffee(App.upc, walletValue, {
          from: App.metamaskAccountID,
          value: walletValue
        });

      console.log("buyCoffee", result);
    } catch (error) {
      console.log(error.message);
    }
  },

  shipCoffee: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));
    try {
      const contract = await App.contracts.SupplyChain.deployed();
      const result = await contract.shipCoffee(App.upc, {
        from: App.metamaskAccountID
      });
      console.log("shipCoffee", result);
    } catch (error) {
      console.log(error.message);
    }
  },

  receiveCoffee: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));

    try {
      const contract = await App.contracts.SupplyChain.deployed();
      const result = await contract.receiveCoffee(App.upc, { from: App.metamaskAccountID });
      console.log("receiveCoffee", result);
    } catch (error) {
      console.log(error.message);
    }
    

        

  },

  purchaseCoffee: async function(event) {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));

    try {
      const contract = await App.contracts.SupplyChain.deployed();

      const walletValue = web3.toWei(App.productPrice, "ether");
      const result = await contract
        .purchaseCoffee(App.upc, {
          from: App.metamaskAccountID,
          value: walletValue
        });

      console.log("purchaseCoffee", result);
    } catch (error) {
      console.log(error.message);
    }
  },

  trackCoffeeBufferOne: function() {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));
    App.upc = $("#upc").val();
    console.log("upc", App.upc);

    App.contracts.SupplyChain.deployed()
      .then(function(instance) {
        return instance.trackCoffeeBufferOne(App.upc);
      })
      .then(function(result) {
        document.getElementById("trackone").style.display = "block";
        $("#ftc-sku").text("SKU:" + result[0]);
        $("#ftc-sellingprice").text(
          "Selling Price: " + web3.fromWei(result[1], "ether") + " ETH"
        );
        $("#ftc-purchasingprice").text("Purchasing Price:" + + web3.fromWei(result[2], "ether") + " ETH");
        $("#ftc-stateis").text("State:" + result[3]);
        $("#ftc-productupc").text("UPC:" + result[4]);
        $("#ftc-farm").text("Farm:" + result[5]);
        $("#ftc-organizationinfo").text("Farm Info:" + result[6]);
      })
      .catch(function(err) {
        console.log(err.message);
      });
  },

  trackCoffeeBufferTwo: function() {
    event.preventDefault();
    var processId = parseInt($(event.target).data("id"));

    App.contracts.SupplyChain.deployed()
      .then(function(instance) {
        return instance.trackCoffeeBufferTwo.call(App.upc);
      })
      .then(function(result) {
        document.getElementById("tracktwo").style.display = "block";
        $("#ftc-lat").text("Latitude:" + result[1]);
        $("#ftc-long").text("Longitude:" + result[2]);
        $("#ftc-notes").text("Additional notes:" + result[3]);
        $("#ftc-farmer").text("Farmer:" + result[4]);
        $("#ftc-buyer").text("Distributor:" + result[5]);
        $("#ftc-retailer").text("Retailer:" + result[6]);
        $("#ftc-consumer").text("Consumer:" + result[7]);
      })
      .catch(function(err) {
        console.log(err.message);
      });
  },

  fetchEvents: function() {
    if (
      typeof App.contracts.SupplyChain.currentProvider.sendAsync !== "function"
    ) {
      App.contracts.SupplyChain.currentProvider.sendAsync = function() {
        return App.contracts.SupplyChain.currentProvider.send.apply(
          App.contracts.SupplyChain.currentProvider,
          arguments
        );
      };
    }

    App.contracts.SupplyChain.deployed()
      .then(function(instance) {
        var events = instance.allEvents(function(err, log) {
          if (!err)
            $("#ftc-events").append(
              "<li>" + log.event + " - " + log.transactionHash + "</li>"
            );
        });
      })
      .catch(function(err) {
        console.log(err.message);
      });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});
