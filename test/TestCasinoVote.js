var CasinoToken = artifacts.require("CasinoToken");

contract('CasinoToken', function(accounts) {

    it("should create poll and voting correctly", function() {
        // todo
        var token;
        var events;

        var owner_acc = accounts[0];
        var vote_acc = accounts[1];

        var initialSupply = 1000000;
        var voteAmount = 10;
        var candidateId = 1;

        return CasinoToken.deployed().then(function (instance) {
            token = instance;

            events = instance.allEvents({from: vote_acc});
            events.watch(function (err, log) {
                console.log(log);
                console.log("");
            });

            return token.registerUser(vote_acc, {from: vote_acc});
        }).then(function (res) {
            return token.getBalance.call({from: vote_acc});
        }).then(function (balance){
            assert.equal(100, balance.toNumber());
            return token.getBalance.call({from: owner_acc});
        }).then(function (balance) {
            assert.equal(initialSupply - 100, balance.toNumber(), "there's amount to be transferred to second account now");
            return token.createPoll(3, 100, {from: owner_acc});
        }).then(function () {
            return token.getBalance.call({from: owner_acc});
        }).then(function (balance) {
            assert.equal(initialSupply - 100 - 500, balance.toNumber(), "the amount of creating poll should be deducted from acc's balance");
            return token.voteOnCandidate(candidateId, voteAmount, {from: vote_acc});
        }).then(function () {
            return token.voteStatus(candidateId, {from: owner_acc});
        }).then(function (votedAmount) {
            assert.equal(votedAmount, voteAmount, "Should be the same as vote_acc has voted");

            return token.getBalance.call({from: vote_acc});
        }).then(function (value) {
            assert.equal(100 - voteAmount, value.toNumber(), "the amount from vote should be deducted from acc's balance");

            events.stopWatching();
            return token.evaluatePoll.call({from: owner_acc});
        }).then(function (value) {
            return token.viewWinningCandidate.call({from: owner_acc});

        }).then(function (value) {
            assert.equal(value.toNumber(), candidateId, "Winning candidate should be the first one");

        }).then(function () {
            // Check balance of vote_account
            return token.getBalance.call({from: vote_acc});
        }).then(function (value) {
            assert.equal(100 - voteAmount + (voteAmount * 2), value.toNumber(), "The amount of vote_acc's balance should increased");
        });
    });

});