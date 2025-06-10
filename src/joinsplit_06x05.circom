pragma circom 2.0.6;
include "./library/joinsplit.circom";

component main{public [merkleRoot, boundParamsHash, nullifiers, commitmentsOut]} = JoinSplit(6, 5,16);