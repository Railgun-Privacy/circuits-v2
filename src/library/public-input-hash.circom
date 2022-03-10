pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";

template PublicInputHash(nInputs, nOutputs){
    signal input merkleRoot;
    signal input nullifiers[nInputs];
    signal input commitmentsOut[nOutputs];
    signal input boundParamsHash;
    signal output out;

    // All input signals are assumed to be 256-bits
    var size = 256 * (nInputs + nOutputs + 2);
    component sha256 = Sha256(size);

    // Bitify input signals
    component n2bMerkleRoot = Num2Bits(256);
    n2bMerkleRoot.in <== merkleRoot;

    component n2bNullifiers[nInputs];
    for(var i=0; i<nInputs; i++) {
        n2bNullifiers[i] = Num2Bits(256);
        n2bNullifiers[i].in <== nullifiers[i];
    }

    component n2bOutCommitments[nOutputs];
    for(var i=0; i<nOutputs; i++) {
        n2bOutCommitments[i] = Num2Bits(256);
        n2bOutCommitments[i].in <== commitmentsOut[i];
    }
    
    component n2bBoundParamsHash = Num2Bits(256);
    n2bBoundParamsHash.in <== boundParamsHash;

    // Set bits in SHA256 component
    for(var i=0; i<256; i++) {
        sha256.in[255 - i] <== n2bMerkleRoot.out[i];
    }
    var offset = 256; 

    for(var j=0; j<nInputs; j++) {
        for(var i=0; i<256; i++) {
            sha256.in[offset + 255 - i] <== n2bNullifiers[j].out[i];
        }
        offset = offset + 256; 
    }

    for(var j=0; j<nOutputs; j++) {
        for(var i=0; i<256; i++) {
            sha256.in[offset + 255 - i] <== n2bOutCommitments[j].out[i];
        }
        offset = offset + 256; 
    }
    
    for(var i=0; i<256; i++) {
        sha256.in[offset + 255 - i] <== n2bBoundParamsHash.out[i];
    }

    component b2n = Bits2Num(256);
    for (var i = 0; i < 256; i++) {
        b2n.in[i] <== sha256.out[255-i];
    }
    
    out <== b2n.out;
}