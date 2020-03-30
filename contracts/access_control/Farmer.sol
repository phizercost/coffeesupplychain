pragma solidity >=0.4.24;

import "../../libraries/UserRoles.sol";


contract Farmer {
    using UserRoles for UserRoles.Role;

    UserRoles.Role private farmers;

    event FarmerAdded(address farmer);
    event FarmerRemoved(address farmer);

    modifier onlyFarmer() {
        require(isFarmer(msg.sender), "This can only be done by a farmer");
        _;
    }

    function _addFarmer(address farmer) internal {
        farmers.addUserToRole(farmer);
        emit FarmerAdded(farmer);
    }

    constructor() public {
        _addFarmer(msg.sender);
    }

    function isFarmer(address farmerAddress) public view returns (bool) {
        return farmers.has(farmerAddress);
    }

    function addFarmer(address farmerAddress) public onlyFarmer {
        _addFarmer(farmerAddress);
    }

    function renounceFarmer() public onlyFarmer {
        _removeFarmer(msg.sender);
    }

    function _removeFarmer(address farmerAddress) internal {
        farmers.removeUserFromRole(farmerAddress);
        emit FarmerRemoved(farmerAddress);
    }
}
