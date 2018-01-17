
function getCasinoToken(success, contractName) {
    $.ajax({
        url: "/contract_token",
        type: "POST",
        data: {
            "token": contractName
        },
        success: function (result) {
            success(result);
        },
        error: function (err) {
            console.log(err);
        }
    });
}

var accounts;
var account;
var truffleContract;
var eventListener;

function initAcc() {
    console.log("Init Web3JS");

    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function(err, accs) {
        if (err != null) {
            alert("There was an error fetching your accounts.");
            return;
        }

        if (accs.length === 0) {
            alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
            return;
        }

        accounts = accs;
        account = accounts[0];

        $('#TTAccount').text(account);
        console.log(account);

        web3.eth.getBalance(account, function(err, result){
            if (!err) {
                $('#TTEthe').text(web3.fromWei(result.toNumber(), "ether"));
            } else {
                alert(err);
            }
        });

        getCasinoToken(function (casinoTokenArtifact){
            console.log(casinoTokenArtifact);
            truffleContract = TruffleContract(casinoTokenArtifact);

            // Set the provider for our contract
            truffleContract.setProvider(web3.currentProvider);

            return getBalance();
        }, "CasinoToken.json");
    });
}

function setStatus(txt){
    $('#TTEvent').text(txt);
}

function getBalance() {
    console.log("Get account balance");

    truffleContract.deployed().then(function (meta) {
        eventListener = meta.allEvents({from: account});
        eventListener.watch(function (err, result) {
            if (err) {
                console.log(err);
            }
            else
                console.log(result);
        });

        return meta.getBalance.call({from: account});
    }).then(function (balance) {
        $('#TTBalance').text(balance.toNumber());

        checkCandidatesAmounts();
    }).catch(function(err) {
        console.log(err);
    });
}


function registerUser () {
    if (account === undefined){
        alert("You don't have any account specified!");
        return;
    }
    setStatus("Register User: " + account);

    truffleContract.deployed().then(function (meta) {
        return meta.registerUser(account, {from: account, gas: 423013});
    }).then(function () {
        setStatus("Registered!");
        console.log("Registered");
        getBalance();
    });
}


function createPoll() {
    console.log("Create a poll");
    setStatus("Create a poll");
    
    truffleContract.deployed().then(function (instance) {
        return instance.createPoll(3, 200, {from: account, gas: 223456});
    });
}

function vote(candidate_id, ca$h) {
    console.log("Vote on candidate: " + candidate_id + " amount: " + ca$h);
    setStatus("Vote on candidate: " + candidate_id + " amount: " + ca$h);

    truffleContract.deployed().then(function (instance) {
        return instance.voteOnCandidate(candidate_id, ca$h, {from: account, gas: 423456});
    });
}

function checkCandidatesAmounts() {
    truffleContract.deployed().then(function (instance) {
        return instance.allVotesStatus();
    }).then(function (amounts) {
        console.log(amounts);
        for (var t = 0; t < amounts.length; t ++){
            console.log(amounts[t].c[0]);
            $("#candidate_" + (t + 1) + "_amount").text(amounts[t].c[0] + " Ca$h");
        }
    });
}

function evalPoll() {
    truffleContract.deployed().then(function (instance) {
        return instance.evaluatePoll({from: account, gas: 645235});
    }).then(function (tickets) {
        console.log(tickets);
    });
}


$(document).ready(function() {
    // Init Web3
    if (typeof web3 !== 'undefined') {
        // Is there an injected web3 instance?
        web3 = new Web3(web3.currentProvider);
    } else {
        // CasinoRoyal.web3Provider = new Web3.providers.HttpProvider("http://localhost:8545");
        web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
    }

    initAcc();

});
