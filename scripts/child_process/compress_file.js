const zlib = require("node:zlib");
const fs = require("node:fs/promises");
const { runWorker } = require("../../lib/shared.js");

async function main(args) {
  await fs.writeFile(
    args.destination,
    zlib.brotliCompressSync(await fs.readFile(args.source), {
      params: {
        [zlib.constants.BROTLI_PARAM_QUALITY]:
          zlib.constants.BROTLI_MAX_QUALITY,
        [zlib.constants.BROTLI_PARAM_LGWIN]:
          zlib.constants.BROTLI_MAX_WINDOW_BITS,
        [zlib.constants.BROTLI_PARAM_LGBLOCK]:
          zlib.constants.BROTLI_MAX_INPUT_BLOCK_BITS,
      },
    })
  );
}

void runWorker.child(main);
