pragma circom 2.0.3;
include "./library/joinsplit.circom";

component main{public [merkleRoot, boundParamsHash, nullifiers, commitmentsOut]} = JoinSplit(8,2,16);