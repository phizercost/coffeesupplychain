pragma solidity >=0.4.24;

import "../../libraries/UserRoles.sol";

contract Distributor {
    using UserRoles for UserRoles.Role;

    UserRoles.Role private distributors;
    
    event DistributorAdded(address distributor);
    
    modifier onlyDistributor() {
        require(isDistributor(msg.sender), "This can only be done by a distributor");
        _;
    }

    function _addDistributor(address distributor) internal {
        distributors.addUserToRole(distributor);
        emit DistributorAdded(distributor);
    }

    constructor() public {
        _addDistributor(msg.sender);
    }
    
    function isDistributor(address distributorAddress) public view returns(bool){
        return distributors.has(distributorAddress);
    }
    
    function addDistributor(address distributorAddress) onlyDistributor public {
        _addDistributor(distributorAddress);
    }


}
