const fs = require("fs");
const path = require("path");
const zlib = require("node:zlib");
const circuitConfigs = require("./circuitConfigs.js");

const cache = [];

function circuitConfigToName(circuitConfig) {
  return `${circuitConfig.nullifiers
    .toString()
    .padStart(2, "0")}x${circuitConfig.commitments
    .toString()
    .padStart(2, "0")}`;
}

function getArtifact(nullifiers, commitments) {
  if (!cache[nullifiers]) {
    cache[nullifiers] = [];
  }

  if (!cache[nullifiers][commitments]) {
    cache[nullifiers][commitments] = {
      zkey: zlib.brotliDecompressSync(
        fs.readFileSync(
          path.join(
            __dirname,
            "circuits",
            circuitConfigToName({ nullifiers, commitments }),
            "zkey.br"
          )
        )
      ),
      wasm: zlib.brotliDecompressSync(
        fs.readFileSync(
          path.join(
            __dirname,
            "circuits",
            circuitConfigToName({ nullifiers, commitments }),
            "wasm.br"
          )
        )
      ),
      vkey: JSON.parse(
        fs.readFileSync(
          path.join(
            __dirname,
            "circuits",
            circuitConfigToName({ nullifiers, commitments }),
            "vkey.json"
          )
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
        path.join(
          __dirname,
          "circuits",
          circuitConfigToName({ nullifiers, commitments }),
          "vkey.json"
        )
      )
    );
  }

  return cache[nullifiers][commitments].vkey;
}

function listArtifacts() {
  return circuitConfigs;
}

module.exports = {
  getArtifact,
  getVKey,
  listArtifacts,
};
