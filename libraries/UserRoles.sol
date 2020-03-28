pragma solidity >=0.4.24;

library UserRoles {
    
    
    struct Role{
        mapping (address => bool) user;
    }
    
    function has(Role storage role, address addressToCheck) internal view returns (bool) {
        require(addressToCheck != address(0));
        return role.user[addressToCheck];
    }
    
    function addUserToRole(Role storage role, address userAddress) internal {
        require(userAddress != address(0));
        require(!has(role, userAddress));
        
        role.user[userAddress] = true;
    }
    
    function removeUserFromRole(Role storage role, address userAddress) internal {
        require(userAddress != address(0));
        require(has(role, userAddress));
        
        role.user[userAddress] = false;
    }
}