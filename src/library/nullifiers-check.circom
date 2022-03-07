pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/babyjub.circom";

template NullifiersCheck(nInputs) {
  signal input leavesIndices[nInputs];
  signal input nullifyingKey;
  signal input nullifiers[nInputs];

  component hash[nInputs];

  for(var i=0; i<nInputs; i++) {
    hash[i] = Poseidon(2);
    hash[i].inputs[0] <== leavesIndices[i];
    hash[i].inputs[1] <== nullifyingKey;
    hash[i].out === nullifiers[i];
  }
}