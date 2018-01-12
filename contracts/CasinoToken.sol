pragma solidity ^0.4.18;

import '../node_modules/zeppelin-solidity/contracts/token/BasicToken.sol';
import '../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol';

contract CasinoToken is BasicToken, Ownable {

    // Protects users by preventing the execution of method calls that
    // inadvertently also transferred ether
    modifier noEther() {require(msg.value > 0); _;}

    /* Predefined values */
    string public name = "Casino Royal Token";
    string public symbol = "Ca$h";
    uint8 public decimals = 18;
    uint public INITIAL_SUPPLY = 1000000;
    uint public PRE_SUPPLY = 100;

    struct Poll {
        string title;
        mapping (address => mapping(uint => uint)) voterToCandidates;
        uint[] amountsPerCandidates;
        uint _expiredTime;
    }

    Poll currentPoll;
    uint indexOfWinner = 0;

    function createPoll(string _title, uint _nrOfCandidates, uint _expiredMin) public {
        currentPoll = Poll(_title, new uint[](_nrOfCandidates), now + 10 minutes);
    }

    function voteOnCandidate(uint _candidateId, uint _amount) public {        
        require(currentPoll._expiredTime >= now);
        require(currentPoll.voterToCandidates[msg.sender][_candidateId] == 0);
        currentPoll.amountsPerCandidates[_candidateId] += _amount;
        currentPoll.voterToCandidates[msg.sender][_candidateId] = _amount;
    }

    function evaluatePoll() public {
        require(currentPoll._expiredTime < now);
        uint mostVotes = 0;
        for (uint x = 0; x < currentPoll.amountsPerCandidates.length; x ++) {
            if (currentPoll.amountsPerCandidates[x] > mostVotes) {
                mostVotes = currentPoll.amountsPerCandidates[x];
                indexOfWinner = x;
            }
        }        
    }

    /* Event happens when new user registered */
    event UserAdded(address user);

    /* Notify when a new transaction is made */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Test event callback*/
    event CallbackEvent(uint256 value, string s);

    /* Define our token constructor */
    function CasinoToken() public {
        totalSupply = INITIAL_SUPPLY;
        // Give all main supply to contract's creator.
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    function transferFrom(address _from, address _to, uint256 _value) private returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    function definePreSupply(uint _newValue) onlyOwner public {
        PRE_SUPPLY = _newValue;
    }

    function registerUser(address _to) public returns (bool success) {
        require(balances[_to] == 0);
        UserAdded(_to);
        // Supply new user with a pre supply amount of token so she scan start playing       
        return transferFrom(owner, _to, PRE_SUPPLY);
    }

    function eventCallback() public {
        CallbackEvent(PRE_SUPPLY, "456646846");
    }

    function getBalance() public returns (uint256 balance) {
        UserAdded(msg.sender);
        return balanceOf(msg.sender);
    }

}