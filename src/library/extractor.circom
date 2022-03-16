pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/bitify.circom";
include "./utils.circom";

template Extractor() {
  // in is 249-bits field in Note 
  // in[0-127] is a 128-bit randomness
  // in[128-247] is a 120-bit value
  // in[248] is the sign of yPublicKey
  signal input in; 
  signal output random;
  signal output value;
  signal output sign;

  component n2b = Num2Bits(249);
  n2b.in <== in;


  component b2nRandom = Bits2Num(128);
  for(var i=0; i<128; i++) {
    b2nRandom.in[i] <== n2b.out[i];
  }
  random <== b2nRandom.out;

  component b2nValue = Bits2Num(120);
  for(var i=0; i<120; i++) {
    b2nValue.in[i] <== n2b.out[128 + i];
  }
  value <== b2nValue.out;

  sign <== n2b.out[248];
}