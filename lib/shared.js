const process = require("node:process");
const fs = require("node:fs");
const os = require("node:os");
const minimist = require("minimist");
const { fork, spawn } = require("node:child_process");

/**
 * Convert array to hex
 * @param {Uint8Array} array - array to convert
 * @param {number} byteLength - byte length of array
 * @returns hex string
 */
function arrayToHex(array, byteLength) {
  return Buffer.from(array)
    .toString("hex")
    .padStart(byteLength * 2, "0");
}

/**
 * Check if path exists (file or directory)
 * @param {string} path - path to check
 * @returns {boolean} exists
 */
function pathExists(path) {
  return fs.existsSync(path);
}

/**
 * Parse CLI arguments
 * @returns {{[arg: string]: any}} arguments
 */
function cliArguments() {
  return minimist(process.argv);
}

/**
 * Runs program, optionally printing output to console
 * @param {string} program - program to run
 * @param {string[]} args - command args
 * @param {import("node:child_process").SpawnOptionsWithoutStdio} options - spawn options
 * @param {boolean} print - print output to console
 * @returns output
 */
function run(program, args = [], options, print = false) {
  return new Promise((res) => {
    const runner = spawn(program, args, options);
    const output = [];

    runner.stdout.on("data", (data) => {
      output.push(data.toString());
      if (print) process.stdout.write(data);
    });

    runner.stderr.on("data", (data) => {
      output.push(data.toString());
      if (print) process.stderr.write(data);
    });

    runner.on("close", (code) => {
      res({
        output,
        code,
      });
    });
  });
}

const runWorker = {
  /**
   * Run compute in thread
   * @param {string} threadPath - path to thread code
   * @param {*} args - arguments to pass to thread
   * @returns result
   */
  parent: (threadPath, args) => {
    return new Promise((res) => {
      // Use full fork instead of worker so child process can run workers (eg. snarkjs)
      const worker = fork(threadPath);
      worker.send(args);
      worker.on("message", res);
    });
  },
  /**
   * Run function in thread
   * @param {function} func - function (optionally async)
   */
  child: (func) => {
    process.on("message", async (msg) => {
      process.send((await func(msg)) || "complete");
      process.exit();
    });
  },
};

/**
 * Runs concurrent tasks, intended for use with (optionally async)
 * functions that spawn threads
 * @param {function[]} tasks - list of (async) functions to run
 * @param {number} concurrency - concurrency (defaults to os.availableParallelism())
 * @returns complete
 */
function processParallel(tasks, concurrency = os.availableParallelism()) {
  return new Promise((res) => {
    const localTasks = [...tasks];
    const results = [];

    let resolved = false;

    const runNext = async () => {
      if (localTasks.length > 0) {
        const task = localTasks.shift()();
        results.push(task);
        await task;
        runNext();
      } else if (!resolved) {
        resolved = true;
        res(Promise.all(results));
      }
    };

    for (let i = 1; i < concurrency; i += 1) runNext();
  });
}

/**
 * Converts circuit config to name
 * @param {*} circuitConfig
 */
function circuitConfigToName(circuitConfig) {
  return `${circuitConfig.nullifiers
    .toString()
    .padStart(2, "0")}x${circuitConfig.commitments
    .toString()
    .padStart(2, "0")}`;
}

module.exports = {
  arrayToHex,
  pathExists,
  cliArguments,
  run,
  runWorker,
  processParallel,
  circuitConfigToName,
};
