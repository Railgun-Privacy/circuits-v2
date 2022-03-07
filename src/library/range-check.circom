pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/bitify.circom";

template RangeCheck(nOutputs) {
  signal input value[nOutputs];
  component n2b[nOutputs];

  for(var i=0; i<nOutputs; i++) {
    n2b[i] = Num2Bits(120);
    n2b[i].in <== value[i];
  }
}