pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/bitify.circom";
include "./utils.circom";

template Extractor() {
  // in is 249-bits field in Note 
  // in[0] is the sign of yPublicKey
  // in[1-128] is a 128-bit randomness
  // in[129-248] is a 120-bit value
  signal input in; 
  signal output sign;
  signal output random;
  signal output value;

  component n2b = Num2Bits(249);
  n2b.in <== in;

  sign <== n2b.out[0];

  var offset = 1;
  var i = 0;

  component b2nRandom = Bits2Num(128);
  for(i=0; i<128; i++) {
    b2nRandom.in[i] <== n2b.out[offset + i];
  }
  random <== b2nRandom.out;

  offset = offset + 128;
  component b2nValue = Bits2Num(120);
  for(i=0; i<120; i++) {
    b2nValue.in[i] <== n2b.out[offset + i];
  }
  value <== b2nValue.out;
}