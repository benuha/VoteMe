pragma solidity ^0.4.18;

library Math {
    struct Matrix {
        int a;
        int b;
    }

    function addInt(Matrix storage s, int b) view public returns (int c) {
        return s.a*b + s.b;
    }
}

contract Sample {
    
    event Acknowledge(string string2, bytes mBytes);

    using Math for *;
    Math.Matrix s1;
    string myString = "";
    bytes myRawString;

    function sample(string initString, bytes rawStringInit) public returns (string myString2, bytes myBytes) {
        myString2 = myString;
        
        myString = initString;

        string memory myString3 = "ABCDE";

        return;

        myString3 = "XYZZ";

        myRawString = rawStringInit;
        myRawString.length++;

        // string myString4 = "example";

        // string myString5 = initString;

        // myString3 = myString4 + myString5;

        s1 = Math.Matrix(2, 9);
        Math.addInt(s1, 23);

        Acknowledge(myString3, myRawString);
        return (myString2, myRawString);

    }
}
