pragma circom 2.0.6;
include "../../node_modules/circomlib/circuits/eddsaposeidon.circom";
include "./merkle-proof-verifier.circom";
include "./nullifier-check.circom";

template JoinSplit(nInputs, nOutputs, MerkleTreeDepth) {

    //********************** Public Signals *********************************
    signal input merkleRoot; // Merkle proofs of membership signals
    signal input boundParamsHash; // hash of ciphertext and adapterParameters
    signal input nullifiers[nInputs]; // Nullifiers for input notes
    signal input commitmentsOut[nOutputs]; // hash of output notes
    //***********************************************************************

    //********************** Private Signals ********************************
    signal input token;
	signal input publicKey[2]; // Public key for signature verification denoted to as PK
	signal input signature[3]; // EDDSA signature (R, s) where R is a point (x,y) and s is a scalar
    signal input randomIn[nInputs];
    signal input valueIn[nInputs];
    signal input pathElements[nInputs][MerkleTreeDepth]; // Merkle proofs of membership 
    signal input leavesIndices[nInputs];
    signal input nullifyingKey;
    signal input npkOut[nOutputs]; // Recipients' NPK
    signal input valueOut[nOutputs];
    //***********************************************************************    

    // 1. Compute hash over public signals to get the signed message
    // 2. Verify EDDSA signature
    // 3. Verify nullifiers
    // 4. Compute master public key
    // 5. Verify Merkle proofs of membership
    // 6. Verify output range
    // 7. Verify output commitments
    // 8. Verify balance property

    var size = nInputs + nOutputs + 2;
    component messageHash = Poseidon(size);
    messageHash.inputs[0] <== merkleRoot;
    messageHash.inputs[1] <== boundParamsHash;
    for(var i=0; i<nInputs; i++) {
        messageHash.inputs[i+2] <== nullifiers[i];
    }
    for(var i=0; i<nOutputs; i++) {
        messageHash.inputs[i+2+nInputs] <== commitmentsOut[i];
    }

    // 2. Verify EDDSA signature over hash of public inputs
    component eddsaVerifier = EdDSAPoseidonVerifier();
    eddsaVerifier.enabled <== 1;
    eddsaVerifier.Ax <== publicKey[0];
    eddsaVerifier.Ay <== publicKey[1];
    eddsaVerifier.R8x <== signature[0];
    eddsaVerifier.R8y <== signature[1];
    eddsaVerifier.S <== signature[2];
    eddsaVerifier.M <== messageHash.out;

    // 3. Verify nullifiers
    component nullifiersHash[nInputs];
    for(var i=0; i<nInputs; i++) {
        nullifiersHash[i] = NullifierCheck();
        nullifiersHash[i].nullifyingKey <== nullifyingKey;
        nullifiersHash[i].leafIndex <== leavesIndices[i];
        nullifiersHash[i].nullifier <== nullifiers[i];
    }

    // 4. Compute master public key
    component mpk = Poseidon(3);
    mpk.inputs[0] <== publicKey[0];
    mpk.inputs[1] <== publicKey[1];
    mpk.inputs[2] <== nullifyingKey;

    // 5. Verify Merkle proofs of membership
    component noteCommitmentsIn[nInputs];
    component npkIn[nInputs]; // note public keys
    component merkleVerifier[nInputs];
    var sumIn = 0;

    for(var i=0; i<nInputs; i++) {
        // Compute NPK
        npkIn[i] = Poseidon(2);
        npkIn[i].inputs[0] <== mpk.out;
        npkIn[i].inputs[1] <== randomIn[i];
        // Compute note commitment
        noteCommitmentsIn[i] = Poseidon(3);
        noteCommitmentsIn[i].inputs[0] <== npkIn[i].out;
        noteCommitmentsIn[i].inputs[1] <== token;
        noteCommitmentsIn[i].inputs[2] <== valueIn[i];

        merkleVerifier[i] = MerkleProofVerifier(MerkleTreeDepth);
        merkleVerifier[i].leaf <== noteCommitmentsIn[i].out;
        merkleVerifier[i].leafIndex <== leavesIndices[i];
        for(var j=0; j<MerkleTreeDepth; j++) {
            merkleVerifier[i].pathElements[j] <== pathElements[i][j];
        }
        merkleVerifier[i].merkleRoot <== merkleRoot;
        sumIn = sumIn + valueIn[i];
    }

    component n2b[nOutputs];
    component outNoteHash[nOutputs];
    var sumOut = 0;
    for(var i=0; i<nOutputs; i++){
        // 6. Verify output value is 120-bits
        n2b[i] = Num2Bits(120);
        n2b[i].in <== valueOut[i];

        // 7. Verify output commitments
        outNoteHash[i] = Poseidon(3);
        outNoteHash[i].inputs[0] <== npkOut[i];
        outNoteHash[i].inputs[1] <== token;
        outNoteHash[i].inputs[2] <== valueOut[i];
        outNoteHash[i].out === commitmentsOut[i];

        sumOut = sumOut + valueOut[i];
    }

    // 8. Verify balance property
    sumIn === sumOut;
}