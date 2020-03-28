pragma solidity >=0.4.24;

import "../access_control/Farmer.sol";
import "../access_control/Distributor.sol";
import "../access_control/Retailer.sol";
import "../access_control/Consumer.sol";
import "../core/Ownable.sol";

contract SupplyChain is Ownable, Farmer, Distributor, Retailer, Consumer {

    uint skuCount;
    enum State { NonExistant, Harvested, Processed, Packed, Added, Bought, Shipped, Received, Purchased }
    struct Coordinates {
        string lat;
        string long;
    }
    struct CoffeeLot {
        uint  sku;
        uint buyingPrice;
        uint sellingPrice;
        State  state;
        string productUpc;
        string originationInformation;
        string farm;
        string organizationInfo;
        Coordinates coordinates;
        string notes;
        address farmer;
        address  buyer;
        address  retailer;
        address consumer;
    }
    mapping (uint => CoffeeLot) coffeeLots;
    event Harvested(uint skuCount);
    event Processed(uint sku);
    event Packed(uint sku);
    event Added(uint sku);
    event Bought(uint sku);
    event Shipped(uint sku);
    event Received(uint sku);
    event Purchased(uint sku);
    modifier verifyCaller (address _address) {
        require(msg.sender == _address, "Do not have the right to call this function");
        _;
    }
    modifier paidEnough(uint _price) {
        require(msg.value >= _price, "Have not paid enough");
        _;
    }
    modifier readyForProcessing(uint _sku) {
        require(coffeeLots[_sku].state == State.Harvested, "Not ready for processing");
        _;
    }
    modifier readyForPacking(uint _sku) {
        require(coffeeLots[_sku].state == State.Processed, "Not ready for packing");
        _;
    }
    modifier readyForAdding(uint _sku) {
        require(coffeeLots[_sku].state == State.Packed, "Not ready for adding");
        _;
    }
    modifier readyForBuying(uint _sku) {
        require(coffeeLots[_sku].state == State.Added, "Not ready for buying");
        _;
    }
    modifier readyForShipping(uint _sku) {
        require(coffeeLots[_sku].state == State.Bought, "Not ready for shipping");
        _;
    }
    modifier readyForReceiving(uint _sku) {
        require(coffeeLots[_sku].state == State.Shipped, "Not ready for receiving");
        _;
    }
    modifier readyForPurchasing(uint _sku) {
        require(coffeeLots[_sku].state == State.Received, "Not ready for purchasing");
        _;
    }
    modifier checkValue(uint _sku, uint _checkType) {
        _;
        uint _price;
        if (_checkType == 1){
           _price = coffeeLots[_sku].buyingPrice;
        } else {
          _price = coffeeLots[_sku].sellingPrice;
        }
        uint amountToRefund = msg.value - _price;
        if (_checkType == 1){
            coffeeLots[_sku].buyer.transfer(amountToRefund);
        }else {
            coffeeLots[_sku].consumer.transfer(amountToRefund);
        }
    }
    constructor() public payable {
        origOwner = msg.sender;
        skuCount = 0;
    }
    function harvestCoffee(string _productUpc, uint _buyingPrice, string _originationInformation, string _farm, string _organizationInfo, string _longitude, string _latitude, string _notes, address _farmer) onlyFarmer public {
        skuCount = skuCount + 1;

        emit Harvested(skuCount);

        Coordinates memory _coordinates = Coordinates({lat: _latitude, long: _longitude});
        coffeeLots[skuCount] = CoffeeLot({sku: skuCount, buyingPrice: _buyingPrice, sellingPrice: 0, state: State.Harvested, productUpc: _productUpc, originationInformation: _originationInformation, farm: _farm, organizationInfo: _organizationInfo, coordinates: _coordinates, notes: _notes, farmer: _farmer, buyer: 0, retailer: 0, consumer: 0});

    }
    function processCoffee(uint sku) onlyFarmer readyForProcessing(sku) verifyCaller(coffeeLots[sku].farmer)  public {
        coffeeLots[sku].state = State.Processed;
        emit Processed(sku);
    }
    function packCoffee(uint sku) onlyFarmer readyForPacking(sku) verifyCaller(coffeeLots[sku].farmer)  public {
        coffeeLots[sku].state = State.Packed;
        emit Packed(sku);
    }
    function addCoffee(uint sku) onlyFarmer readyForAdding(sku) verifyCaller(coffeeLots[sku].farmer)  public {
        coffeeLots[sku].state = State.Added;
        emit Added(sku);
    }
    function buyCoffee(uint sku, uint buyingPrice) onlyDistributor readyForBuying(sku) paidEnough(coffeeLots[sku].buyingPrice) checkValue(sku, 1)  public payable{
        address buyer = msg.sender;
        uint price = coffeeLots[sku].buyingPrice;
        coffeeLots[sku].buyer = buyer;
        coffeeLots[sku].sellingPrice = buyingPrice;
        coffeeLots[sku].state = State.Bought;
        coffeeLots[sku].farmer.transfer(price);
        emit Bought(sku);
    }
    function shipCoffee(uint sku) onlyFarmer readyForShipping(sku) verifyCaller(coffeeLots[sku].farmer)  public {
        coffeeLots[sku].state = State.Shipped;
        //emit Shipped(sku);
    }
    function receiveCoffee(uint sku) onlyRetailer readyForReceiving(sku) public  {
        address retailer = msg.sender;
        coffeeLots[sku].retailer = retailer;
        coffeeLots[sku].state = State.Received;
        emit Received(sku);
    }
    function purchaseCoffee(uint sku) onlyConsumer readyForPurchasing(sku) paidEnough(coffeeLots[sku].sellingPrice) checkValue(sku, 0)  public payable{
        address consumer = msg.sender;
        uint sellingPrice = coffeeLots[sku].sellingPrice;
        coffeeLots[sku].consumer = consumer;
        coffeeLots[sku].state = State.Purchased;
        coffeeLots[sku].buyer.transfer(sellingPrice);
        emit Purchased(sku);
    }
    function trackCoffeeBufferOne(uint _sku) public view returns ( uint sku, uint buyingPrice,uint sellingPrice, string stateIs,string productUpc, string originationInformation, string farm, string organizationInfo) {
        sku = coffeeLots[_sku].sku;
        uint state;
        buyingPrice = coffeeLots[_sku].buyingPrice;
        sellingPrice = coffeeLots[_sku].sellingPrice;
        state = uint(coffeeLots[_sku].state);
        if( state == 1) {
            stateIs = "Harvested";
        }
        if( state == 2) {
            stateIs = "Processed";
        }
        if( state == 3) {
            stateIs = "Packed";
        }
        if( state == 4) {
            stateIs = "Added";
        }
        if( state == 5) {
            stateIs = "Bought";
        }
        if( state == 6) {
            stateIs = "Shipped";
        }
        if( state == 7) {
            stateIs = "Received";
        }
        if( state == 8) {
            stateIs = "Purchased";
        }
        productUpc = coffeeLots[_sku].productUpc;
        originationInformation = coffeeLots[_sku].originationInformation;
        farm = coffeeLots[_sku].farm;
        organizationInfo = coffeeLots[_sku].organizationInfo;
    }
    function trackCoffeeBufferTwo(uint _sku) public view returns ( uint sku, string lat, string long, string notes,  address farmer, address buyer, address retailer, address consumer) {
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