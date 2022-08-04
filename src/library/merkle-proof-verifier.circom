pragma circom 2.0.6;
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/switcher.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";

template MerkleProofVerifier(MerkleTreeDepth) {
    signal input leaf;
    signal input leafIndex; 
    signal input pathElements[MerkleTreeDepth];
    signal input merkleRoot;
    signal input enabled;

    component hashers[MerkleTreeDepth];
    component switchers[MerkleTreeDepth];

    // Bitify leafIndex to get bit per each level
    component index = Num2Bits(MerkleTreeDepth);
    index.in <== leafIndex;

    var levelHash;
    levelHash = leaf;

    for (var i = 0; i < MerkleTreeDepth; i++) {
        switchers[i] = Switcher();
        switchers[i].L <== levelHash;
        switchers[i].R <== pathElements[i];
        switchers[i].sel <== index.out[i];
        hashers[i] = Poseidon(2);
        hashers[i].inputs[0] <== switchers[i].outL;
        hashers[i].inputs[1] <== switchers[i].outR;
        levelHash = hashers[i].out;
    }
    
    component isEqual = ForceEqualIfEnabled();
    isEqual.enabled <== enabled;
    isEqual.in[0] <== merkleRoot;
    isEqual.in[1] <== levelHash;
}