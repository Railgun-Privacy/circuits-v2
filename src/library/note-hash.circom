pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/poseidon.circom";

template NoteHash() {
  // y coordianate of master public key
  signal input yPublicKey; 
  signal input in;
  signal input token;
  
  signal output hash;

  component poseidon = Poseidon(3);
  poseidon.inputs[0] <== yPublicKey;
  poseidon.inputs[1] <== in;
  poseidon.inputs[2] <== token;

  hash <== poseidon.out;
}