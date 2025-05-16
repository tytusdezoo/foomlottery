#!/usr/bin/node

const { ethers } = require("ethers");
const { bigintToHex, hexToBigint } = require("./utils/bigint.js");
const { mimcsponge3 } = require("./utils/mimcsponge.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);
  const index = hexToBigint(inputs[0]);
  const newRand = hexToBigint(inputs[1]);
  const newLeaves = await Promise.all(inputs.slice(2,inputs.length).map(async (h,j) => await mimcsponge3(h,newRand,index+BigInt(j))));
  const res = ethers.AbiCoder.defaultAbiCoder().encode( ["uint[]"], [newLeaves.map((x) => bigintToHex(x))]);
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
