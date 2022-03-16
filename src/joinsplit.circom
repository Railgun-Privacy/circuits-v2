pragma circom 2.0.3;
include "../node_modules/circomlib/circuits/eddsaposeidon.circom";
include "./library/public-input-hash.circom";
include "./library/nullifiers-check.circom";
include "./library/note-hash.circom";
include "./library/utils.circom";
include "./library/extractor.circom";
include "./library/merkle-proof-verifier.circom";
include "./library/range-check.circom";

template JoinSplit(nInputs, nOutputs, MerkleTreeDepth) {

    // MPK: Master public key, a field used in the notes commitment
    // VPK: EDDSA Signature verification public key
    // nk: nullifying key is a private scalar
    // MPK = VPK^{nk}
    // Note.hash = Poseidon(MPK, packed, token)
    // Note.nullifier = Poseidon(note's index in the Merkle tree, nullifigyKey, random)
    // packed is 249-bits signal that consists of (random, value, sign) at locations (0-127, 128-247, 248)
    // token is 254-bits signal of the asset (ERC20 address padded with zeroes or NFT globally unique identifier)

    // The only public signal which is used to reduce verification cost
    signal input hashOfPublicInput;
    
    // All following signals are private
    signal input boundParamsHash;
    signal input token;
    // Public key for signature verification denoted to as SPK
	signal input publicKey[2];
    // EDDSA signature (R, s) where R is a point (x,y) and s is a scalar
	signal input signature_R[2];
    signal input signature_S;
    // Packed input field is 249-bits (random, value, sign) at locations (0-127, 128-247, 248)
    signal input packedIn[nInputs];

    // Merkle proofs of membership signals
    signal input merkleRoot;
    signal input pathElements[nInputs][MerkleTreeDepth];
    signal input leavesIndices[nInputs];

    // NullifyingKey is a private scalar denoted to as snk
    signal input nullifyingKey;
    // Nullifiers for input notes
    signal input nullifiers[nInputs];

    // Recipients' master public key denoted to as MPK
    // to is the y coordinate of MPK for each output
    signal input to[nOutputs]; 
    // Packed output field is 249-bits (random, value, sign) at locations (0-127, 128-247, 248)
    signal input packedOut[nOutputs];
    // hash of output notes
    signal input commitmentsOut[nOutputs];

    // 1. Verifiy hash of public input
    // 2. Verify EDDSA signature
    // 3. Verify nullifiers
    // 4. Compute master public key
    // 5. Verify Merkle proofs of membership
    // 6. Verify output range
    // 7. Verify output commitments
    // 8. Verify balance property

    // 1. Verify hash of public input
    component publicInputHash = PublicInputHash(nInputs, nOutputs);
    publicInputHash.merkleRoot <== merkleRoot;
    for(var i=0; i<nInputs; i++) {
        publicInputHash.nullifiers[i] <== nullifiers[i];
	}
    for(var i=0; i<nOutputs; i++) {
        publicInputHash.commitmentsOut[i] <== commitmentsOut[i];
	}
    publicInputHash.boundParamsHash <== boundParamsHash;
    publicInputHash.out === hashOfPublicInput;

    // 2. Verify EDDSA signature over hash of public inputs
    component eddsaVerifier = EdDSAPoseidonVerifier();
    eddsaVerifier.enabled <== 1;
    eddsaVerifier.Ax <== publicKey[0];
    eddsaVerifier.Ay <== publicKey[1];
    eddsaVerifier.S <== signature_S;
    eddsaVerifier.R8x <== signature_R[0];
    eddsaVerifier.R8y <== signature_R[1];
    eddsaVerifier.M <== hashOfPublicInput;

    // 3. Verify nullifiers
    component nullifiersCheck = NullifiersCheck(nInputs);
    nullifiersCheck.nullifyingKey <== nullifyingKey;
    for(var i=0; i<nInputs; i++) {
        nullifiersCheck.leavesIndices[i] <== leavesIndices[i];
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
    component inExtractor[nInputs];
    var sumIn = 0;
    for(var i=0; i<nInputs; i++) {
        inNoteHash[i] = NoteHash();
        inNoteHash[i].yPublicKey <== packedMPK.y;
        inNoteHash[i].in <== packedIn[i];
        inNoteHash[i].token <== token;

        merkleVerifier[i] = MerkleProofVerifier(MerkleTreeDepth);
        merkleVerifier[i].leaf <== inNoteHash[i].hash;
        merkleVerifier[i].leafIndex <== leavesIndices[i];
        for(var j=0; j<MerkleTreeDepth; j++) {
            merkleVerifier[i].pathElements[j] <== pathElements[i][j];
        }
        merkleVerifier[i].merkleRoot === merkleRoot;

        inExtractor[i] = Extractor();
        inExtractor[i].in <== packedIn[i];
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
        outNoteHash[i].yPublicKey <== to[i];
        outNoteHash[i].in <== packedOut[i];
        outNoteHash[i].token <== token;
        outNoteHash[i].hash === commitmentsOut[i];
    }

    // 8. Verify balance property
    sumIn === sumOut;
}