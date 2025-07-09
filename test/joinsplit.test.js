const assert = require("node:assert");
const tester = require("circom_tester").wasm;
const vectors = require("./vectors.json");
const circuitConfigs = require("../lib/circuitConfigs");
const { circuitConfigToName } = require("../lib/shared");

function formatCircuitInputs(inputs) {
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

describe("Joinsplit", () => {
  // Loop through all circuits
  for (const circuitConfig of circuitConfigs) {
    const circuitName = circuitConfigToName(circuitConfig);
    const circuitPath = `./src/generated/${circuitName}.circom`;

    // Create tests for circuit
    describe(circuitName, () => {
      let circuit;
      let originalInputs;

      before(async () => {
        if (!vectors.testInputs[circuitName])
          throw new Error(`Inputs for ${circuitName} not found in vectors`);
        originalInputs = formatCircuitInputs(vectors.testInputs[circuitName]);
        circuit = await tester(circuitPath, { reduceConstraints: false });
      });

      it(`Should generate proof with valid inputs`, async () => {
        const witness = await circuit.calculateWitness(originalInputs);
        await circuit.checkConstraints(witness);
      });

      it("Should fail when merkleRoot is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          merkleRoot: originalInputs.merkleRoot + 1n,
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when boundParamsHash is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          boundParamsHash: originalInputs.boundParamsHash + 1n,
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when nullifiers is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          nullifiers: [
            ...originalInputs.nullifiers.slice(0, -1),
            originalInputs.nullifiers.at(-1) + 1n,
          ],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when commitmentsOut is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          commitmentsOut: [
            ...originalInputs.commitmentsOut.slice(0, -1),
            originalInputs.commitmentsOut.at(-1) + 1n,
          ],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when token is incorrect", async () => {
        const mutated = { ...originalInputs, token: originalInputs.token + 1n };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when publicKey is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          publicKey: [
            ...originalInputs.publicKey.slice(0, -1),
            originalInputs.publicKey.at(-1) + 1n,
          ],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when signature is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          signature: [
            ...originalInputs.signature.slice(0, -1),
            originalInputs.signature.at(-1) + 1n,
          ],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when randomIn is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          randomIn: [
            ...originalInputs.randomIn.slice(0, -1),
            originalInputs.randomIn.at(-1) + 1n,
          ],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when valueIn is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          valueIn: [
            ...originalInputs.valueIn.slice(0, -1),
            originalInputs.valueIn.at(-1) + 1n,
          ],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when pathElements is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          pathElements: originalInputs.pathElements.map((pe, i) =>
            i === 0 ? [...pe.slice(0, -1), pe.at(-1) + 1n] : pe,
          ),
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when leavesIndices is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          leavesIndices: [
            ...originalInputs.leavesIndices.slice(0, -1),
            originalInputs.leavesIndices.at(-1) + 1n,
          ],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when nullifyingKey is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          nullifyingKey: originalInputs.nullifyingKey + 1n,
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when npkOut is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          npkOut: [
            ...originalInputs.npkOut.slice(0, -1),
            originalInputs.npkOut.at(-1) + 1n,
          ],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it("Should fail when valueOut is incorrect", async () => {
        const mutated = {
          ...originalInputs,
          valueOut: [
            ...originalInputs.valueOut.slice(0, -1),
            originalInputs.valueOut.at(-1) + 1n,
          ],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });
    });
  }
});
