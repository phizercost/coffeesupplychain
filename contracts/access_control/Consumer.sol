pragma solidity >=0.4.24;


import "../../libraries/UserRoles.sol";

contract Consumer {
    using UserRoles for UserRoles.Role;

    UserRoles.Role private consumers;
    
    event ConsumerAdded(address consumer);
    
    modifier onlyConsumer() {
        require(isConsumer(msg.sender), "This can only be done by a consumer");
        _;
    }

    function _addConsumer(address consumer) internal {
        consumers.addUserToRole(consumer);
        emit ConsumerAdded(consumer);
    }

    constructor() public {
        _addConsumer(msg.sender);
    }
    
    function isConsumer(address consumerAddress) public view returns(bool){
        return consumers.has(consumerAddress);
    }
    
    function addConsumer(address consumerAddress) onlyConsumer public {
        _addConsumer(consumerAddress);
    }
}
