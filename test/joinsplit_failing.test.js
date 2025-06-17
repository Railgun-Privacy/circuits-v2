const tester = require('circom_tester').wasm;
const fs = require('fs').promises;
const assert = require('assert');
const { convertToBigInt } = require('./utils/formatInputs');
const testData = require('./utils/merkle_tree_and_test_inputs.json').testInputs;

describe('Joinsplit All Circuits Failing', () => {
  // Generate all valid circuit configs
  const circuitList = [];
  for (let i = 1; i <= 14; i++) {
    for (let j = 1; j <= 14 - i; j++) {
      if (i + j + 2 + 1 > 17) continue;
      circuitList.push({ nullifiers: i, commitments: j });
    }
  }

  for (const { nullifiers, commitments } of circuitList) {
    const suffix = `${String(nullifiers).padStart(2, '0')}x${String(commitments).padStart(2, '0')}`;
    const label = `Joinsplit ${suffix}`;
    const inputKey = `inputs_${suffix}`;

    describe(label, () => {
      let original;
      let circuit;

      before(async () => {
        const circuitPath = `./src/joinsplit_${suffix}.circom`;
        const inputs = testData[inputKey];
        original = convertToBigInt(inputs);
        circuit = await tester(circuitPath, { reduceConstraints: false });
      });

      it('Should fail when merkleRoot is incorrect', async () => {
        const mutated = { ...original, merkleRoot: original.merkleRoot + 1n };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when boundParamsHash is incorrect', async () => {
        const mutated = { ...original, boundParamsHash: original.boundParamsHash + 1n };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when nullifiers is incorrect', async () => {
        const mutated = {
          ...original,
          nullifiers: [...original.nullifiers.slice(0, -1), original.nullifiers.at(-1) + 1n],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when commitmentsOut is incorrect', async () => {
        const mutated = {
          ...original,
          commitmentsOut: [...original.commitmentsOut.slice(0, -1), original.commitmentsOut.at(-1) + 1n],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when token is incorrect', async () => {
        const mutated = { ...original, token: original.token + 1n };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when publicKey is incorrect', async () => {
        const mutated = {
          ...original,
          publicKey: [...original.publicKey.slice(0, -1), original.publicKey.at(-1) + 1n],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when signature is incorrect', async () => {
        const mutated = {
          ...original,
          signature: [...original.signature.slice(0, -1), original.signature.at(-1) + 1n],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when randomIn is incorrect', async () => {
        const mutated = {
          ...original,
          randomIn: [...original.randomIn.slice(0, -1), original.randomIn.at(-1) + 1n],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when valueIn is incorrect', async () => {
        const mutated = {
          ...original,
          valueIn: [...original.valueIn.slice(0, -1), original.valueIn.at(-1) + 1n],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when pathElements is incorrect', async () => {
        const mutated = {
          ...original,
          pathElements: original.pathElements.map((pe, i) =>
            i === 0 ? [...pe.slice(0, -1), pe.at(-1) + 1n] : pe
          ),
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when leavesIndices is incorrect', async () => {
        const mutated = {
          ...original,
          leavesIndices: [...original.leavesIndices.slice(0, -1), original.leavesIndices.at(-1) + 1n],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when nullifyingKey is incorrect', async () => {
        const mutated = { ...original, nullifyingKey: original.nullifyingKey + 1n };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when npkOut is incorrect', async () => {
        const mutated = {
          ...original,
          npkOut: [...original.npkOut.slice(0, -1), original.npkOut.at(-1) + 1n],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });

      it('Should fail when valueOut is incorrect', async () => {
        const mutated = {
          ...original,
          valueOut: [...original.valueOut.slice(0, -1), original.valueOut.at(-1) + 1n],
        };
        await assert.rejects(() => circuit.calculateWitness(mutated));
      });
    });
  }
});
