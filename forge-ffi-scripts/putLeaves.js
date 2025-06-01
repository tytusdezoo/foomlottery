#!/usr/bin/node

const { hexToBigint } = require("./utils/bigint.js");
const { putLeaves } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() { // TODO: test if update is correct
  const inputs = process.argv.slice(2, process.argv.length);
  const newIndex = parseInt(inputs[0],16);
  const newRand = hexToBigint(inputs[1]);
  const newRoot = hexToBigint(inputs[2]);
  const blockNumber = parseInt(inputs[3],16);
  await putLeaves(newIndex,newRand,newRoot,blockNumber);
}

main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
