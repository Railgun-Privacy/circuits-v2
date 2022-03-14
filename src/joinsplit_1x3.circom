pragma circom 2.0.3;
include "./joinsplit.circom";

component main{public [hashOfPublicInput]} = JoinSplit(1,3,16);