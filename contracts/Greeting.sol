pragma solidity ^0.4.18;

contract TheOwner {
    address owner;

    function TheOwner() public {
        owner = msg.sender;
    }

    function sepuku() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }
}

contract MyGreeter is TheOwner {
    string greeting;

    function MyGreeter(string _greeting) public {
        greeting = _greeting;
    }

    function greet() constant public returns (string) {
        return greeting;
    }
}