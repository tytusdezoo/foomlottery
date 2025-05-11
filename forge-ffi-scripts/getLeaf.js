#!/usr/bin/node

const { ethers } = require("ethers");
const { bigintToHex, hexToBigint } = require("./utils/bigint.js");
const { mimcsponge2 } = require("./utils/mimcsponge.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);

  const index = hexToBigint(inputs[0]);
  const hash = hexToBigint(inputs[1]);
  const rand = hexToBigint(inputs[2]);
  const leaf = await mimcsponge2(hash,rand+index);

  const res = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint"],
    [bigintToHex(leaf)]
  );
  return res;
}

main()
  .then((res) => {
    process.stdout.write(res);
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
