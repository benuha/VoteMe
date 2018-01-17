pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/CasinoToken.sol";

contract TestCasinoToken {

    /* Test Initial Balance */
    function testInitialBalance() public {
        CasinoToken cas = CasinoToken(DeployedAddresses.CasinoToken());

        uint expected = 1000000;        

        Assert.equal(cas.balanceOf(tx.origin), expected, "The balance of this contract should be the same as the initial balance!");
    }

    /* Test create poll */
    function testCreatePoll() public {
        CasinoToken cas = CasinoToken(DeployedAddresses.CasinoToken());

        cas.createPoll(3, 2);

        uint voteAmount = 10;
        uint first_candidateId = 0;
        uint second_candidateId = 1;
        uint third_candidateId = 2;

        Assert.equal(cas.voteStatus(first_candidateId), 0, "first_candidateId should be zero");
        Assert.equal(cas.voteStatus(second_candidateId), 0, "second_candidateId should be zero");
        Assert.equal(cas.voteStatus(third_candidateId), 0, "third_candidateId should be zero");
//
//        cas.voteOnCandidate(first_candidateId, voteAmount);
//        Assert.equal(cas.voteStatus(first_candidateId), voteAmount, "Should be the amount of vote");

        // cas.voteOnCandidate(second_candidateId, voteAmount * 2);
        // Assert.equal(cas.voteStatus(second_candidateId), voteAmount * 2, "Should be the amount of vote");


//         Assert.equal(cas.viewWinningCandidate(), 0, "No Winner yet");

//         cas.evaluatePoll();
//         Assert.equal(cas.viewWinningCandidate(), second_candidateId, "We should have got a champion now!");
    }    
}
