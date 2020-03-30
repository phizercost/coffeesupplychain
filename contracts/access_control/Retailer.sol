pragma solidity >=0.4.24;

import "../../libraries/UserRoles.sol";


contract Retailer {
    using UserRoles for UserRoles.Role;

    UserRoles.Role private retailers;

    event RetailerAdded(address retailer);
    event RetailerRemoved(address retailer);

    modifier onlyRetailer() {
        require(isRetailer(msg.sender), "This can only be done by a retailer");
        _;
    }

    function _addRetailer(address retailer) internal {
        retailers.addUserToRole(retailer);
        emit RetailerAdded(retailer);
    }

    constructor() public {
        _addRetailer(msg.sender);
    }

    function isRetailer(address retailerAddress) public view returns (bool) {
        return retailers.has(retailerAddress);
    }

    function addRetailer(address retailerAddress) public onlyRetailer {
        _addRetailer(retailerAddress);
    }

    function renounceRetailer() public onlyRetailer {
        _removeRetailer(msg.sender);
    }

    function _removeRetailer(address retailerAddress) internal {
        retailers.removeUserFromRole(retailerAddress);
        emit RetailerRemoved(retailerAddress);
    }
}
