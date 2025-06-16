const tester = require('circom_tester').wasm;
const fs = require('fs').promises;
const { convertToBigInt } = require('./utils/formatInputs');

describe('Joinsplit All Circuits Correctness', () => {
  let testData;

  before(async () => {
    // Load test inputs once
    const data = await fs.readFile('./test/utils/merkle_tree_and_test_inputs.json', 'utf8');
    testData = JSON.parse(data).testInputs;
  });

  // Generate all valid circuit configs
  const circuitList = [];
  for (let i = 1; i <= 14; i++) {
    for (let j = 1; j <= 14 - i; j++) {
      if (i + j + 2 + 1 > 17) continue;
      circuitList.push({ nullifiers: i, commitments: j });
    }
  }

  // Dynamically test each joinsplit circuit
  for (const { nullifiers, commitments } of circuitList) {
    const suffix = `${String(nullifiers).padStart(2, '0')}x${String(commitments).padStart(2, '0')}`;
    const label = `Joinsplit ${suffix}`;
    const inputKey = `inputs_${suffix}`;

    it(`Should verify ${label}`, async () => {
      const circuitPath = `./src/joinsplit_${String(nullifiers).padStart(2, '0')}x${String(commitments).padStart(2, '0')}.circom`;
      const circuit = await tester(circuitPath, { reduceConstraints: false });

      const inputs = testData[inputKey];
      if (!inputs) throw new Error(`Inputs for ${fileSuffix} not found in JSON`);

      const convertedInputs = convertToBigInt(inputs);
      const witness = await circuit.calculateWitness(convertedInputs);
      await circuit.checkConstraints(witness);
    });
  }
});