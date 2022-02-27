pragma circom 2.0.3;

include "../../node_modules/circomlib/circuits/bitify.circom";

template RangeCheck(nOutput) {
  signal input value[nOutput];
  component n2b[nOutput];

  for(var i=0; i<nOutput; i++) {
    n2b[i] = Num2Bits(120);
    n2b[i].in <== value[i];
  }
}