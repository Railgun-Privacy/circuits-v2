pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/poseidon.circom";

template Nullifier(MerkleTreeDepth) {
  signal input leafIndex;
  signal input nullifyingKey;

  signal output out;

  component poseidon = Poseidon(2);
  poseidon.inputs[0] <== leafIndex;
  poseidon.inputs[1] <== nullifyingKey;

  out <== poseidon.out;
}