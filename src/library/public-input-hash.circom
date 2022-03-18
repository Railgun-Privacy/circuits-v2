pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/poseidon.circom";

template PublicInputHash(nInputs, nOutputs){
    signal input merkleRoot;
    signal input boundParamsHash;
    signal input nullifiers[nInputs];
    signal input commitmentsOut[nOutputs];
    signal output out;

    var size = nInputs + nOutputs + 2;
    component poseidon = Poseidon(size);
    poseidon.inputs[0] <== merkleRoot;
    poseidon.inputs[1] <== boundParamsHash;
    
    var offset = 2;
    for(var i=0; i<nInputs; i++) {
        poseidon.inputs[i+offset] <== nullifiers[i];
    }

    offset += nInputs;
    for(var i=0; i<nOutputs; i++) {
        poseidon.inputs[i+offset] <== commitmentsOut[i];
    }
    
    out <== poseidon.out;
}