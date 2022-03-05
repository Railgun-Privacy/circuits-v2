pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/pointbits.circom";

template Extractor() {
  signal input pubY;
  // in is 248-bits field in Note 
  // in[0] is the sign of pubY
  // in[1-128] is a 128-bit randomness
  // in[129-248] is a 120-bit value
  signal input in; 
  signal output publicKey[2];
  signal output random;
  signal output value;

  component n2b = Num2Bits(248);
  n2b.in <== in;

  component unpackPoint = UnpackPoint();
  unpackPoint.y <== pubY;
  unpackPoint.sign <== n2b.out[0];
  publicKey[0] <== unpackPoint.out[0];
  publicKey[1] <== unpackPoint.out[1];

  var offset = 1;
  var i = 0;

  component b2nRandom = Bits2Num(128);
  for(i=0; i<128; i++) {
    b2nRandom.in[i] <== n2b.out[offset + 1];
  }
  random <== b2nRandom.out;

  offset = offset + 128;
  component b2nValue = Bits2Num(120);
  for(i=0; i<120; i++) {
    b2nValue.in[i] <== n2b.out[offset + 1];
  }
  value <== b2nValue.out;
}

template UnpackPoint(){
    signal input y;
    signal input sign;

    signal output out[2];

    component n2bY = Num2Bits(254);
    n2bY.in <== y;

    component b2Point = Bits2Point_Strict();

    for (var i = 0; i < 254; i++) {
        b2Point.in[i] <== n2bY.out[i];
    }

    b2Point.in[254] <== 0;
    b2Point.in[255] <== sign;

    out[0] <== b2Point.out[0];
    out[1] <== b2Point.out[1];
}
