pragma solidity >=0.4.24;

import "../access_control/Farmer.sol";
import "../access_control/Distributor.sol";
import "../access_control/Retailer.sol";
import "../access_control/Consumer.sol";
import "../core/Ownable.sol";


contract SupplyChain is Ownable, Farmer, Distributor, Retailer, Consumer {
    uint256 skuCount;
    enum State {
        NonExistant,
        Harvested,
        Processed,
        Packed,
        Advertised,
        Bought,
        Shipped,
        Received,
        Purchased
    }
    struct Coordinates {
        string lat;
        string long;
    }
    struct CoffeeLot {
        uint256 sku;
        uint256 sellingPrice;
        uint256 purchasingPrice;
        State state;
        uint256 productUpc;
        string farm;
        string organizationInfo;
        Coordinates coordinates;
        string notes;
        address farmer;
        address buyer;
        address retailer;
        address consumer;
    }
    mapping(uint256 => CoffeeLot) coffeeLots;
    event Harvested(uint256 upc);
    event Processed(uint256 upc);
    event Packed(uint256 upc);
    event Advertised(uint256 upc);
    event Bought(uint256 upc);
    event Shipped(uint256 upc);
    event Received(uint256 upc);
    event Purchased(uint256 upc);
    modifier verifyCaller(address _address) {
        require(
            msg.sender == _address,
            "Do not have the right to call this function"
        );
        _;
    }
    modifier paidEnough(uint256 _price) {
        require(msg.value >= _price, "Have not paid enough");
        _;
    }
    modifier readyForProcessing(uint256 _upc) {
        require(
            coffeeLots[_upc].state == State.Harvested,
            "Not ready for processing"
        );
        _;
    }
    modifier readyForPacking(uint256 _upc) {
        require(
            coffeeLots[_upc].state == State.Processed,
            "Not ready for packing"
        );
        _;
    }
    modifier readyForAdvertising(uint256 _upc) {
        require(
            coffeeLots[_upc].state == State.Packed,
            "Not ready for advertising"
        );
        _;
    }
    modifier readyForBuying(uint256 _upc) {
        require(
            coffeeLots[_upc].state == State.Advertised,
            "Not ready for buying"
        );
        _;
    }
    modifier readyForShipping(uint256 _upc) {
        require(
            coffeeLots[_upc].state == State.Bought,
            "Not ready for shipping"
        );
        _;
    }
    modifier readyForReceiving(uint256 _upc) {
        require(
            coffeeLots[_upc].state == State.Shipped,
            "Not ready for receiving"
        );
        _;
    }
    modifier readyForPurchasing(uint256 _upc) {
        require(
            coffeeLots[_upc].state == State.Received,
            "Not ready for purchasing"
        );
        _;
    }
    modifier checkValue(uint256 _upc, uint256 _checkType) {
        _;
        uint256 _price;
        if (_checkType == 1) {
            _price = coffeeLots[_upc].sellingPrice;
        } else {
            _price = coffeeLots[_upc].purchasingPrice;
        }
        uint256 amountToRefund = msg.value - _price;
        if (_checkType == 1) {
            coffeeLots[_upc].buyer.transfer(amountToRefund);
        } else {
            coffeeLots[_upc].consumer.transfer(amountToRefund);
        }
    }

    constructor() public payable {
        origOwner = msg.sender;
        skuCount = 0;
    }

    function harvestCoffee(
        uint256 _productUpc,
        string _farm,
        string _organizationInfo,
        string _longitude,
        string _latitude,
        string _notes,
        address _farmer
    ) public onlyFarmer {
        skuCount = skuCount + 1;

        emit Harvested(skuCount);

        Coordinates memory _coordinates = Coordinates({
            lat: _latitude,
            long: _longitude
        });
        coffeeLots[_productUpc] = CoffeeLot({
            sku: skuCount,
            sellingPrice: 0,
            purchasingPrice: 0,
            state: State.Harvested,
            productUpc: _productUpc,
            farm: _farm,
            organizationInfo: _organizationInfo,
            coordinates: _coordinates,
            notes: _notes,
            farmer: _farmer,
            buyer: 0,
            retailer: 0,
            consumer: 0
        });
    }

    function processCoffee(uint256 upc)
        public
        onlyFarmer
        readyForProcessing(upc)
        verifyCaller(coffeeLots[upc].farmer)
    {
        coffeeLots[upc].state = State.Processed;
        emit Processed(upc);
    }

    function packCoffee(uint256 upc)
        public
        onlyFarmer
        readyForPacking(upc)
        verifyCaller(coffeeLots[upc].farmer)
    {
        coffeeLots[upc].state = State.Packed;
        emit Packed(upc);
    }

    function advertiseCoffee(uint256 upc, uint256 sellingPrice)
        public
        onlyFarmer
        readyForAdvertising(upc)
        verifyCaller(coffeeLots[upc].farmer)
    {
        coffeeLots[upc].sellingPrice = sellingPrice;
        coffeeLots[upc].state = State.Advertised;
        emit Advertised(upc);
    }

    function buyCoffee(uint256 upc, uint256 consumerPriceToSet)
        public
        payable
        onlyDistributor
        readyForBuying(upc)
        paidEnough(coffeeLots[upc].sellingPrice)
        checkValue(upc, 1)
    {
        address buyer = msg.sender;
        uint256 price = coffeeLots[upc].sellingPrice;
        coffeeLots[upc].buyer = buyer;
        coffeeLots[upc].purchasingPrice = consumerPriceToSet;
        coffeeLots[upc].state = State.Bought;
        coffeeLots[upc].farmer.transfer(price);
        emit Bought(upc);
    }

    function shipCoffee(uint256 upc)
        public
        onlyFarmer
        readyForShipping(upc)
        verifyCaller(coffeeLots[upc].farmer)
    {
        coffeeLots[upc].state = State.Shipped;
        emit Shipped(upc);
    }

    function receiveCoffee(uint256 upc)
        public
        onlyRetailer
        readyForReceiving(upc)
    {
        address retailer = msg.sender;
        coffeeLots[upc].retailer = retailer;
        coffeeLots[upc].state = State.Received;
        emit Received(upc);
    }

    function purchaseCoffee(uint256 upc)
        public
        payable
        onlyConsumer
        readyForPurchasing(upc)
        paidEnough(coffeeLots[upc].purchasingPrice)
        checkValue(upc, 0)
    {
        address consumer = msg.sender;
        uint256 purchasingPrice = coffeeLots[upc].purchasingPrice;
        coffeeLots[upc].consumer = consumer;
        coffeeLots[upc].state = State.Purchased;
        coffeeLots[upc].buyer.transfer(purchasingPrice);
        emit Purchased(upc);
    }

    function trackCoffeeBufferOne(uint256 _upc)
        public
        view
        returns (
            uint256 sku,
            uint256 sellingPrice,
            uint256 purchasingPrice,
            string stateIs,
            uint256 productUpc,
            string farm,
            string organizationInfo
        )
    {
        sku = coffeeLots[_upc].sku;
        uint256 state;
        sellingPrice = coffeeLots[_upc].sellingPrice;
        purchasingPrice = coffeeLots[_upc].purchasingPrice;
        state = uint256(coffeeLots[_upc].state);
        if (state == 1) {
            stateIs = "Harvested";
        }
        if (state == 2) {
            stateIs = "Processed";
        }
        if (state == 3) {
            stateIs = "Packed";
        }
        if (state == 4) {
            stateIs = "Advertised";
        }
        if (state == 5) {
            stateIs = "Bought";
        }
        if (state == 6) {
            stateIs = "Shipped";
        }
        if (state == 7) {
            stateIs = "Received";
        }
        if (state == 8) {
            stateIs = "Purchased";
        }
        productUpc = coffeeLots[_upc].productUpc;
        farm = coffeeLots[_upc].farm;
        organizationInfo = coffeeLots[_upc].organizationInfo;

        return (
            sku,
            sellingPrice,
            purchasingPrice,
            stateIs,
            productUpc,
            farm,
            organizationInfo
        );
    }

    function trackCoffeeBufferTwo(uint256 _upc)
        public
        view
        returns (
            uint256 sku,
            string lat,
            string long,
            string notes,
            address farmer,
            address buyer,
            address retailer,
            address consumer
        )
    {
        sku = coffeeLots[_upc].sku;
        lat = string(coffeeLots[_upc].coordinates.lat);
        long = string(coffeeLots[_upc].coordinates.long);
        notes = coffeeLots[_upc].notes;
        farmer = coffeeLots[_upc].farmer;
        buyer = coffeeLots[_upc].buyer;
        retailer = coffeeLots[_upc].retailer;
        consumer = coffeeLots[_upc].consumer;
        return (sku, lat, long, notes, farmer, buyer, retailer, consumer);
    }
}
