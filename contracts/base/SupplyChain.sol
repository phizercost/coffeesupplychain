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
        string productUpc;
        string originationInformation;
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
    event Harvested(uint256 skuCount);
    event Processed(uint256 sku);
    event Packed(uint256 sku);
    event Advertised(uint256 sku);
    event Bought(uint256 sku);
    event Shipped(uint256 sku);
    event Received(uint256 sku);
    event Purchased(uint256 sku);
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
    modifier readyForProcessing(uint256 _sku) {
        require(
            coffeeLots[_sku].state == State.Harvested,
            "Not ready for processing"
        );
        _;
    }
    modifier readyForPacking(uint256 _sku) {
        require(
            coffeeLots[_sku].state == State.Processed,
            "Not ready for packing"
        );
        _;
    }
    modifier readyForAdvertising(uint256 _sku) {
        require(
            coffeeLots[_sku].state == State.Packed,
            "Not ready for advertising"
        );
        _;
    }
    modifier readyForBuying(uint256 _sku) {
        require(
            coffeeLots[_sku].state == State.Advertised,
            "Not ready for buying"
        );
        _;
    }
    modifier readyForShipping(uint256 _sku) {
        require(
            coffeeLots[_sku].state == State.Bought,
            "Not ready for shipping"
        );
        _;
    }
    modifier readyForReceiving(uint256 _sku) {
        require(
            coffeeLots[_sku].state == State.Shipped,
            "Not ready for receiving"
        );
        _;
    }
    modifier readyForPurchasing(uint256 _sku) {
        require(
            coffeeLots[_sku].state == State.Received,
            "Not ready for purchasing"
        );
        _;
    }
    modifier checkValue(uint256 _sku, uint256 _checkType) {
        _;
        uint256 _price;
        if (_checkType == 1) {
            _price = coffeeLots[_sku].sellingPrice;
        } else {
            _price = coffeeLots[_sku].purchasingPrice;
        }
        uint256 amountToRefund = msg.value - _price;
        if (_checkType == 1) {
            coffeeLots[_sku].buyer.transfer(amountToRefund);
        } else {
            coffeeLots[_sku].consumer.transfer(amountToRefund);
        }
    }
    constructor() public payable {
        origOwner = msg.sender;
        skuCount = 0;
    }
    function harvestCoffee(
        string _productUpc,
        string _originationInformation,
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
        coffeeLots[skuCount] = CoffeeLot({
            sku: skuCount,
            sellingPrice: 0,
            purchasingPrice: 0,
            state: State.Harvested,
            productUpc: _productUpc,
            originationInformation: _originationInformation,
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
    function processCoffee(uint256 sku)
        public
        onlyFarmer
        readyForProcessing(sku)
        verifyCaller(coffeeLots[sku].farmer)
    {
        coffeeLots[sku].state = State.Processed;
        emit Processed(sku);
    }
    function packCoffee(uint256 sku)
        public
        onlyFarmer
        readyForPacking(sku)
        verifyCaller(coffeeLots[sku].farmer)
    {
        coffeeLots[sku].state = State.Packed;
        emit Packed(sku);
    }
    function advertiseCoffee(uint256 sku, uint256 sellingPrice)
        public
        onlyFarmer
        readyForAdvertising(sku)
        verifyCaller(coffeeLots[sku].farmer)
    {
        coffeeLots[sku].sellingPrice = sellingPrice;
        coffeeLots[sku].state = State.Advertised;
        emit Advertised(sku);
    }
    function buyCoffee(uint256 sku, uint256 consumerPriceToSet)
        public
        payable
        onlyDistributor
        readyForBuying(sku)
        paidEnough(coffeeLots[sku].sellingPrice)
        checkValue(sku, 1)
    {
        address buyer = msg.sender;
        uint256 price = coffeeLots[sku].sellingPrice;
        coffeeLots[sku].buyer = buyer;
        coffeeLots[sku].purchasingPrice = consumerPriceToSet;
        coffeeLots[sku].state = State.Bought;
        coffeeLots[sku].farmer.transfer(price);
        emit Bought(sku);
    }
    function shipCoffee(uint256 sku)
        public
        onlyFarmer
        readyForShipping(sku)
        verifyCaller(coffeeLots[sku].farmer)
    {
        coffeeLots[sku].state = State.Shipped;
        emit Shipped(sku);
    }
    function receiveCoffee(uint256 sku)
        public
        onlyRetailer
        readyForReceiving(sku)
    {
        address retailer = msg.sender;
        coffeeLots[sku].retailer = retailer;
        coffeeLots[sku].state = State.Received;
        emit Received(sku);
    }
    function purchaseCoffee(uint256 sku)
        public
        payable
        onlyConsumer
        readyForPurchasing(sku)
        paidEnough(coffeeLots[sku].purchasingPrice)
        checkValue(sku, 0)
    {
        address consumer = msg.sender;
        uint256 purchasingPrice = coffeeLots[sku].purchasingPrice;
        coffeeLots[sku].consumer = consumer;
        coffeeLots[sku].state = State.Purchased;
        coffeeLots[sku].buyer.transfer(purchasingPrice);
        emit Purchased(sku);
    }
    function trackCoffeeBufferOne(uint256 _sku)
        public
        view
        returns (
            uint256 sku,
            uint256 sellingPrice,
            uint256 purchasingPrice,
            string stateIs,
            string productUpc,
            string originationInformation,
            string farm,
            string organizationInfo
        )
    {
        sku = coffeeLots[_sku].sku;
        uint256 state;
        sellingPrice = coffeeLots[_sku].sellingPrice;
        purchasingPrice = coffeeLots[_sku].purchasingPrice;
        state = uint256(coffeeLots[_sku].state);
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
        productUpc = coffeeLots[_sku].productUpc;
        originationInformation = coffeeLots[_sku].originationInformation;
        farm = coffeeLots[_sku].farm;
        organizationInfo = coffeeLots[_sku].organizationInfo;
    }
    function trackCoffeeBufferTwo(uint256 _sku)
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
        sku = coffeeLots[_sku].sku;
        lat = string(coffeeLots[_sku].coordinates.lat);
        long = string(coffeeLots[_sku].coordinates.long);
        notes = coffeeLots[_sku].notes;
        farmer = coffeeLots[_sku].farmer;
        buyer = coffeeLots[_sku].buyer;
        retailer = coffeeLots[_sku].retailer;
        consumer = coffeeLots[_sku].consumer;
    }
}
