pragma circom 2.0.3;
include "../../node_modules/circomlib/circuits/eddsaposeidon.circom";
include "./public-input-hash.circom";
include "./nullifiers-check.circom";
include "./note-hash.circom";
include "./utils.circom";
include "./extractor.circom";
include "./merkle-proof-verifier.circom";
include "./range-check.circom";

template JoinSplit(nInputs, nOutputs, MerkleTreeDepth) {

    // MPK: Master public key, a field used in the notes commitment
    // VPK: EDDSA Signature verification public key
    // nk: nullifying key is a private scalar
    // MPK = VPK^{nk}
    // Note.hash = Poseidon(MPK, packed, token)
    // Note.nullifier = Poseidon(note's index in the Merkle tree, nullifigyKey, random)
    // packed is 249-bits signal that consists of (random, value, sign) at locations (0-127, 128-247, 248)
    // token is 254-bits signal of the asset (ERC20 address padded with zeroes or NFT globally unique identifier)

    //********************** Public Signals *********************************
    // Merkle proofs of membership signals
    signal input merkleRoot;
    // hash of ciphertext and adapterParameters
    signal input boundParamsHash;
    // Nullifiers for input notes
    signal input nullifiers[nInputs];
    // hash of output notes
    signal input commitmentsOut[nOutputs];
    //***********************************************************************

    //********************** Private Signals ********************************
    signal input token;
    // Public key for signature verification denoted to as SPK
	signal input publicKey[2];
    // EDDSA signature (R, s) where R is a point (x,y) and s is a scalar
	signal input signature[3];
    // Packed input field is 249-bits (random, value, sign) at locations (0-127, 128-247, 248)
    signal input packedIn[nInputs];
    // Merkle proofs of membership 
    signal input pathElements[nInputs][MerkleTreeDepth];
    signal input leavesIndices[nInputs];
    // NullifyingKey is a private scalar denoted to as snk
    signal input nullifyingKey;
    // Recipients' MPK (y coordinate)
    signal input to[nOutputs]; 
    // Packed output field is 249-bits (random, value, sign) at locations (0-127, 128-247, 248)
    signal input packedOut[nOutputs];
    //***********************************************************************    

    // 1. Compute hash over public signals to get the signed message
    // 2. Verify EDDSA signature
    // 3. Verify nullifiers
    // 4. Compute master public key
    // 5. Verify Merkle proofs of membership
    // 6. Verify output range
    // 7. Verify output commitments
    // 8. Verify balance property

    component messageHash = PublicInputHash(nInputs, nOutputs);
    messageHash.merkleRoot <== merkleRoot;
    messageHash.boundParamsHash <== boundParamsHash;
    for(var i=0; i<nInputs; i++) {
        messageHash.nullifiers[i] <== nullifiers[i];
    }
    for(var i=0; i<nOutputs; i++) {
        messageHash.commitmentsOut[i] <== commitmentsOut[i];
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
    component inExtractor[nInputs];
    component nullifiersCheck = NullifiersCheck(nInputs);
    nullifiersCheck.nullifyingKey <== nullifyingKey;
    for(var i=0; i<nInputs; i++) {
        inExtractor[i] = Extractor();
        inExtractor[i].in <== packedIn[i];
        nullifiersCheck.leavesIndices[i] <== leavesIndices[i];
        nullifiersCheck.random[i] <== inExtractor[i].random;
        nullifiersCheck.nullifiers[i] <== nullifiers[i];
    }

    // 4. Compute master public key
    component mpk = ECMul();
    mpk.point[0] <== publicKey[0];
    mpk.point[1] <== publicKey[1];
    mpk.scalar <== nullifyingKey;

    component packedMPK = PackPoint();
    packedMPK.in[0] <== mpk.out[0];
    packedMPK.in[1] <== mpk.out[1];

    // 5. Verify Merkle proofs of membership
    component inNoteHash[nInputs];
    component merkleVerifier[nInputs];
    var sumIn = 0;
    for(var i=0; i<nInputs; i++) {
        inNoteHash[i] = NoteHash();
        inNoteHash[i].yMPK <== packedMPK.y;
        inNoteHash[i].packed <== packedIn[i];
        inNoteHash[i].token <== token;

        merkleVerifier[i] = MerkleProofVerifier(MerkleTreeDepth);
        merkleVerifier[i].leaf <== inNoteHash[i].hash;
        merkleVerifier[i].leafIndex <== leavesIndices[i];
        for(var j=0; j<MerkleTreeDepth; j++) {
            merkleVerifier[i].pathElements[j] <== pathElements[i][j];
        }
        merkleVerifier[i].merkleRoot === merkleRoot;

        sumIn = sumIn + inExtractor[i].value;
    }

    // 6. Verify output value is 120-bits
    component outExtractor[nOutputs];
    component rangeCheck = RangeCheck(nOutputs);
    component outNoteHash[nOutputs];
    var sumOut = 0;
    for(var i=0; i<nOutputs; i++){
        outExtractor[i] = Extractor();
        outExtractor[i].in <== packedOut[i];
        rangeCheck.value[i] <== outExtractor[i].value;
        sumOut = sumOut + outExtractor[i].value;

        // 7. Verify output commitments
        outNoteHash[i] = NoteHash();
        outNoteHash[i].yMPK <== to[i];
        outNoteHash[i].packed <== packedOut[i];
        outNoteHash[i].token <== token;
        outNoteHash[i].hash === commitmentsOut[i];
    }

    // 8. Verify balance property
    sumIn === sumOut;
}