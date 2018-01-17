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

    /* Test event callback*/
    event CallbackEvent(address user, uint256 value, string s);

    event VoteCallback(address user, uint256 _amount, uint256 _candidateId);

    // Poll options
    uint public indexOfWinner;
    uint[] public amountsPerCandidates;
    uint public expiredTime;

    mapping (address => uint) voterToTicketIdx;
    Ticket[] public tickets;

    struct Ticket {
        address voter;
        uint candidateIds;
        uint amount;
    }

    function createPoll(uint _nrOfCandidates, uint _expiredInSecond) public {
        require(balances[msg.sender] >= 501);
        balances[msg.sender] -= 500;
        amountsPerCandidates = new uint[](_nrOfCandidates);
        expiredTime = now + _expiredInSecond;
    }

    function voteOnCandidate(uint _candidateId, uint _amount) public {        
//        require(expiredTime >= now);
        require(_candidateId < amountsPerCandidates.length);
        require(_amount > 0);
        require(balances[msg.sender] > _amount);
        // Only those haven't voted before can participate
        require(voterToTicketIdx[msg.sender] == 0);

        amountsPerCandidates[_candidateId] += _amount;
        tickets.push(Ticket(msg.sender, _candidateId, _amount));
        voterToTicketIdx[msg.sender] = tickets.length;
        balances[msg.sender] -= _amount;

        VoteCallback(msg.sender, _amount, _candidateId);
    }

    function evaluatePoll() onlyOwner public returns (Ticket[]) {
//        require(expiredTime < now);
        uint mostVotes = 0;
        for (uint x = 0; x < amountsPerCandidates.length; x ++) {
            if (amountsPerCandidates[x] > mostVotes) {
                mostVotes = amountsPerCandidates[x];
                indexOfWinner = x;
            }
        }

        for (uint tick = 0; tick < tickets.length; tick ++) {
            Ticket storage t = tickets[tick];
            if (t.candidateIds == indexOfWinner) {
                balances[t.voter] += t.amount * 2;
                CallbackEvent(msg.sender, t.amount, "");
            }
        }
        return tickets;
    }

    function terminateContract() onlyOwner public {
        // Transfer Ethe to owner and terminate the contract
        selfdestruct(owner);
    }

    function voteStatus(uint _candidateId) external view returns (uint amount) {
        // This function must not cost any gas
        // Check on the vote of user
        require(_candidateId < amountsPerCandidates.length);
        return amountsPerCandidates[_candidateId];
    }

    function allVotesStatus() external view returns (uint[] amounts) {
        return amountsPerCandidates;
    }

    function viewWinningCandidate() external view returns (uint candidateId) {
        return indexOfWinner;
    }

    /* Event happens when new user registered */
    event UserAdded(address user);

    /* Notify when a new transaction is made */
    event Transfer(address indexed from, address indexed to, uint256 value);

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

    function definePreSupply(uint _newValue) public onlyOwner {
        PRE_SUPPLY = _newValue;
    }

    function registerUser(address _to) public returns (bool success) {
        require(balances[_to] == 0);
        UserAdded(_to);
        // Supply new user with a pre supply amount of token so she scan start playing       
        return transferFrom(owner, _to, PRE_SUPPLY);
    }

    function eventCallback() public {
        CallbackEvent(msg.sender, PRE_SUPPLY, "456646846");
    }

    function getBalance() view public returns (uint256 balance) {
        return balanceOf(msg.sender);
    }

}