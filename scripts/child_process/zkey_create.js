const snarkjs = require("snarkjs");
const { runWorker, arrayToHex } = require("../../lib/shared.js");

async function main(args) {
  return arrayToHex(
    await snarkjs.zKey.newZKey(
      args.r1cs,
      args.ptau,
      args.zkey,
      args.print ? console : undefined,
    ),
    64,
  );
}

void runWorker.child(main);
