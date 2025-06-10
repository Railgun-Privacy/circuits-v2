pragma circom 2.0.6;
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";

template NullifierCheck() {
  signal input nullifier;
  signal input nullifyingKey;
  signal input leafIndex;

  component nullifierHash = Poseidon(2);
  nullifierHash.inputs[0] <== nullifyingKey;
  nullifierHash.inputs[1] <== leafIndex;

  component isEqual = IsEqual();
  isEqual.in[0] <== nullifier;
  isEqual.in[1] <== nullifierHash.out;
  isEqual.out === 1;
}