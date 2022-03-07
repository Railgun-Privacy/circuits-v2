pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/escalarmulany.circom";
include "../../node_modules/circomlib/circuits/escalarmulfix.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";
include "../../node_modules/circomlib/circuits/pointbits.circom";


template ECMulBase() {
  signal input scalar;       // Scalar
  signal output out[2]; // e*Base8
  component pbk = BabyPbk();
  pbk.in <== scalar;
  out[0] <== pbk.Ax;
  out[1] <== pbk.Ay;
}

template ECMul() {
  signal input point[2];
  signal input scalar;

  signal output out[2];

  component n2b = Num2Bits(253);
  n2b.in <== scalar;

  component ecMul = EscalarMulAny(253);
  ecMul.p[0] <== point[0];
  ecMul.p[1] <== point[1];
  for (var i = 0; i < 253; i++) {
      ecMul.e[i] <== n2b.out[i];
  }

  out[0] <== ecMul.out[0];
  out[1] <== ecMul.out[1];
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

template PackPoint() {
  signal input in[2];
  signal output y;
  signal output sign;

  component p2b = Point2Bits_Strict();
  p2b.in[0] <== in[0];
  p2b.in[1] <== in[1];

  component b2n = Bits2Num_strict();
  for(var i=0; i<254; i++) {
    b2n.in[i] <== p2b.out[i];
  }
  y <== b2n.out;
  sign <== p2b.out[255];
}
