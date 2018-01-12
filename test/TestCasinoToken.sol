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

    /* Test register User */
    function testRegisterUser() public {
        CasinoToken cas = CasinoToken(DeployedAddresses.CasinoToken());

        cas.registerUser(tx.origin);
        uint expected = 1000000;

        Assert.equal(cas.balanceOf(tx.origin), expected + 100, "The balance of this contract should be increase by a supply");
    }
    
}
