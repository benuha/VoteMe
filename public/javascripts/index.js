
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
    }).catch(function(err) {
        console.log(err);
    });
}


function registerUser () {
    if (account === undefined){
        alert("You don't have any account specified!");
        return;
    }
    console.log("Register User: " + account);

    truffleContract.deployed().then(function (meta) {
        return meta.registerUser(account, {from: account, gas: 423013});
    }).then(function () {
        setStatus("Registered!");
        getBalance();
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
