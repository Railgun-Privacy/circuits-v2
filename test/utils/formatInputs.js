function convertToBigInt(inputs) {
  const toBigInt = (x) => BigInt(x);
  return {
    merkleRoot: toBigInt(inputs.merkleRoot),
    boundParamsHash: toBigInt(inputs.boundParamsHash),
    nullifiers: inputs.nullifiers.map(toBigInt),
    commitmentsOut: inputs.commitmentsOut.map(toBigInt),
    token: toBigInt(inputs.token),
    publicKey: inputs.publicKey.map(toBigInt),
    signature: inputs.signature.map(toBigInt),
    randomIn: inputs.randomIn.map(toBigInt),
    valueIn: inputs.valueIn.map(toBigInt),
    pathElements: inputs.pathElements.map((pe) => pe.map(toBigInt)),
    leavesIndices: inputs.leavesIndices.map(toBigInt),
    nullifyingKey: toBigInt(inputs.nullifyingKey),
    npkOut: inputs.npkOut.map(toBigInt),
    valueOut: inputs.valueOut.map(toBigInt),
  };
}

module.exports = { convertToBigInt };