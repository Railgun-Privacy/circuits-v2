pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/poseidon.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";

component NullifierCheck() {
  signal input nullifier;
  signal input nullifyingKey;
  signal input leafIndex;
  signal input enabled;

  nullifierHash[i] = Poseidon(2);
  nullifierHash[i].inputs[0] <== nullifyingKey;
  nullifierHash[i].inputs[1] <== leafIndex;
  nullifierHash[i].out === nullifiers[i];

  component isEqual = ForceEqualIfEnabled();
  isEqual.enabled <== enabled;
  isEqual.in[0] <== nullifier;
  isEqual.in[1] <== nullifierHash.out;
}