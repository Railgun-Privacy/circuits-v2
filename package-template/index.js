const fs = require("fs");
const decompress = require("brotli/decompress");

const cache = [];

function getArtifact(nullifiers, commitments) {
  if (!cache[nullifiers]) {
    cache[nullifiers] = [];
  }

  if (!cache[nullifiers][commitments]) {
    cache[nullifiers][commitments] = {
      zkey: decompress(
        fs.readFileSync(
          `${__dirname}/circuits/${nullifiers}x${commitments}/zkey.br`
        )
      ),
      wasm: decompress(
        fs.readFileSync(
          `${__dirname}/circuits/${nullifiers}x${commitments}/wasm.br`
        )
      ),
      vkey: JSON.parse(
        fs.readFileSync(
          `${__dirname}/circuits/${nullifiers}x${commitments}/vkey.json`
        )
      ),
    };
  }

  return cache[nullifiers][commitments];
}

function getVKey(nullifiers, commitments) {
  if (!cache[nullifiers] || !cache[nullifiers][commitments]) {
    return JSON.parse(
      fs.readFileSync(
        `${__dirname}/circuits/${nullifiers}x${commitments}/vkey.json`
      )
    );
  }

  return cache[nullifiers][commitments].vkey;
}

function listArtifacts() {
  const circuitConfigs = [];

  // Every combination of nullifiers and commitments where nullifiers + commitments + 3 <= 17
  for (let nullifiers = 1; nullifiers <= 14; nullifiers += 1) {
    for (
      let commitments = 1;
      commitments <= 14 - nullifiers;
      commitments += 1
    ) {
      circuitConfigs.push({
        nullifiers,
        commitments,
      });
    }
  }

  return circuitConfigs;
}

module.exports = {
  getArtifact,
  getVKey,
  listArtifacts,
};
