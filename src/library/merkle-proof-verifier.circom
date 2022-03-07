pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/switcher.circom";

template MerkleProofVerifier(MerkleTreeDepth) {
    signal input leaf;
    signal input leafIndex; 
    signal input pathElements[MerkleTreeDepth];
    signal output merkleRoot;

    component hashers[MerkleTreeDepth];
    component switchers[MerkleTreeDepth];

    // Bitify pathindices to get bit per each level
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
    
    merkleRoot <== levelHash;
}