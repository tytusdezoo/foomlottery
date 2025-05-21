#!/usr/bin/node
const { readLast, getPath } = require("./utils/mimcMerkleTree.js");
const { bigintToHex } = require("./utils/bigint.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const [nextIndex,blockNumber,lastRoot,lastLeaf] = readLast();  // add lastLeaf
  const pathElements = await getPath(nextIndex-1);
  console.log(pathElements.map((p) => bigintToHex(p)));
  return;
}

main()
  .then((wtns) => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
