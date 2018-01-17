var CasinoToken = artifacts.require("CasinoToken");

contract('CasinoToken', function(accounts) {
    it("should put 1000000 token into first account", function() {
        var events;
        return CasinoToken.deployed().then(function(instance) {

            events = instance.allEvents();
            events.watch(function (err, log) {
                console.log(log);
                return 0;
            });

            return instance.getBalance.call({from: accounts[0]});
        }).then(function(balance) {
            events.stopWatching();
            console.log(balance);
            assert.equal(balance.toNumber(), 1000000, "1000000 wasn't in the first account");
        });
    });

    it("should send coin correctly", function () {
        var token;
        var events;

        // Get balances of first and second accounts
        var first_acc = accounts[0];
        var second_acc = accounts[1];

        var first_acc_starting_balance;
        var first_acc_ending_balance;

        var second_acc_starting_balance;
        var second_acc_ending_balance;

        var amount = 100;

        return CasinoToken.deployed().then(function (instance) {
            token = instance;

            events = instance.allEvents({from: first_acc});
            events.watch(function (err, log) {
                console.log(log);
            });

            return token.getBalance.call({from: first_acc});
        }).then(function (balance) {
            first_acc_starting_balance = balance.toNumber();
            return token.getBalance.call({from: second_acc});
        }).then(function (balance) {
            second_acc_starting_balance = balance.toNumber();
            return token.registerUser(second_acc, {from: second_acc});
        }).then(function (res) {
            //assert.equal(res, true, "transaction must be executed correctly");
            return token.getBalance.call({from: first_acc});
        }).then(function (balance) {
            first_acc_ending_balance = balance.toNumber();
            return token.getBalance.call({from: second_acc});
        }).then(function (balance) {
            second_acc_ending_balance = balance.toNumber();

            events.stopWatching();

            assert.equal(first_acc_starting_balance, first_acc_ending_balance + amount, "Ammount wasn't correctly asserted for First");
            assert.equal(second_acc_starting_balance, second_acc_ending_balance - amount, "Ammount wasn't correctly asserted for Second");
        });
    });


    it("Should show event", function(){
        return CasinoToken.deployed().then(function (instance) {
            return instance.eventCallback();
        });
    });
});