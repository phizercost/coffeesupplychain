pragma solidity >=0.4.24;

contract Ownable {
    address origOwner;
    event TransferOwnership(address indexed oldOwner, address indexed newOwner);
    constructor() internal {
        origOwner = msg.sender;
        emit TransferOwnership(address(0), origOwner);
    }
    function owner() public view returns (address) {
        return origOwner;
    }
    modifier onlyOwner() {
        require(isOwner(), "You are not the owner of this contract");
        _;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == origOwner;
    }
    function renounceOwnership() public onlyOwner {
        emit TransferOwnership(origOwner, address(0));
        origOwner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "You are not the owner of this contract"
        );
        emit TransferOwnership(origOwner, newOwner);
        origOwner = newOwner;
    }
}
