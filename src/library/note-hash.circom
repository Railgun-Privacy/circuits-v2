pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/poseidon.circom";

template NoteHash() {
  signal input yMPK; 
  signal input packed;
  signal input token;
  
  signal output hash;

  component poseidon = Poseidon(3);
  poseidon.inputs[0] <== yMPK;
  poseidon.inputs[1] <== packed;
  poseidon.inputs[2] <== token;

  hash <== poseidon.out;
}