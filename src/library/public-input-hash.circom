pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../../node_modules/circomlib/circuits/bitify.circom";

template PublicInputHash(nInput, nOutput){
    signal input merkleRoot;
    signal input commitmentsOut[nOutput];
    signal input nullifiers[nInput];
    signal input extraParamsHash;

    signal output out;

    // All input signals are assumed to be 256-bits
    var size = 256 * (nInput + nOutput + 2);
    component sha256 = Sha256(size);

    // Bitify input signals
    component n2bMerkleRoot = Num2Bits(256);
    n2bMerkleRoot.in <== merkleRoot;

    component n2bOutCommitments[nOutput];
    for(var i=0; i<nOutput; i++) {
        n2bOutCommitments[i] = Num2Bits(256);
        n2bOutCommitments[i].in <== commitmentsOut[i];
    }

    component n2bNullifiers[nInput];
    for(var i=0; i<nInput; i++) {
        n2bNullifiers[i] = Num2Bits(256);
        n2bNullifiers[i].in <== nullifiers[i];
    }

    component n2bExtraParamsHash = Num2Bits(256);
    n2bExtraParamsHash.in <== extraParamsHash;

    // Set bits in SHA256 component
    for(var i=0; i<256; i++) {
        sha256.in[255 - i] <== n2bMerkleRoot.out[i];
    }
    var offset = 256; 

    for(var j=0; j<nInput; j++) {
        for(var i=0; i<256; i++) {
            sha256.in[offset + 255 - i] <== n2bNullifiers[j].out[i];
        }
        offset = offset + 256; 
    }

    for(var j=0; j<nOutput; j++) {
        for(var i=0; i<256; i++) {
            sha256.in[offset + 255 - i] <== n2bOutCommitments[j].out[i];
        }
        offset = offset + 256; 
    }
    
    for(var i=0; i<256; i++) {
        sha256.in[offset + 255 - i] <== n2bExtraParamsHash.out[i];
    }

    component b2n = Bits2Num(256);
    for (var i = 0; i < 256; i++) {
        b2n.in[i] <== sha256.out[255-i];
    }
    out <== b2n.out;
}