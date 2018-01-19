pragma solidity ^0.4.18;

contract Roulette {

    string welcome;
    uint privSeed;
    struct Casino {
        address addr;
        uint balance;
        uint bettingLimitMin;
        uint bettingLimitMax;
    }
    Casino casino;

    function Roulette() public {
        privSeed = 1;
        welcome = "\n-----------------------------\n     Welcome to Roulette \n-----------------------------\n";
        casino.addr = msg.sender;
        casino.balance = 0;
        casino.bettingLimitMin = 1*10**18;
        casino.bettingLimitMax = 10*10**18;
    }

    function casinoBalance() view public returns (uint) {
        return casino.balance;
    }

    function casinoDeposit() public {
        if (msg.sender == casino.addr)
            casino.balance += msg.value;
        else 
            msg.sender.transfer(msg.value);
    }

    function casinoWithdraw(uint amount) public {
        if (msg.sender == casino.addr && amount <= casino.balance) {
            casino.balance -= amount;
            casino.addr.transfer(amount);
        }
    }

    // Bet on Number
    function betOnNumber(uint number) public returns (string) {
        // Input Handling
        address addr = msg.sender;
        uint betSize = msg.value;
        if (betSize < casino.bettingLimitMin || betSize > casino.bettingLimitMax) {
            // Return Funds
            if (betSize >= 1*10**18)
                addr.transfer(betSize);
            return "Please choose an amount within between 1 and 10 ETH";
        }
        if (betSize * 36 > casino.balance) {
            // Return Funds
            addr.transfer(betSize);
            return "Casino has insufficient funds for this bet amount";
        }
        if (number < 0 || number > 36) {
            // Return Funds
            addr.transfer(betSize);
            return "Please choose a number between 0 and 36";
        }
        // Roll the wheel
        privSeed += 1;
        uint rand = generateRand();
        if (number == rand) {
            // Winner winner chicken dinner!
            uint winAmount = betSize * 36;
            casino.balance -= (winAmount - betSize);
            addr.transfer(winAmount);
            return "Winner winner chicken dinner!";
        } else {
            casino.balance += betSize;
            return "Wrong number.";
        }
    }

    // Returns a pseudo Random number.
    function generateRand() private returns (uint) { 
        // Seeds
        privSeed = (privSeed*3 + 1) / 2;
        privSeed = privSeed % 10**9;
        uint number = block.number; // ~ 10**5 ; 60000
        uint diff = block.difficulty; // ~ 2 Tera = 2*10**12; 1731430114620
        uint time = block.timestamp; // ~ 2 Giga = 2*10**9; 1439147273
        uint gas = block.gaslimit; // ~ 3 Mega = 3*10**6
        // Rand Number in Percent
        uint total = privSeed + number + diff + time + gas;
        uint rand = total % 37;
        return rand;
    }

    // Function to recover the funds on the contract
    function kill() public {
        if (msg.sender == casino.addr) 
            selfdestruct(casino.addr);
    }
}