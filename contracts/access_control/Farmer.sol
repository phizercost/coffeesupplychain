pragma solidity >=0.4.24;

import "../../libraries/UserRoles.sol";

contract Farmer {
    using UserRoles for UserRoles.Role;

    UserRoles.Role private farmers;
    
    event FarmerAdded(address farmer);
    
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
    
    function isFarmer(address farmerAddress) public view returns(bool){
        return farmers.has(farmerAddress);
    }
    
    function addFarmer(address farmerAddress) onlyFarmer public {
        _addFarmer(farmerAddress);
    }


}

