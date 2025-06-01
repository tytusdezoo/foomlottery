#!/usr/bin/node

const { ethers } = require("ethers");
const { update } = require("./utils/mimcMerkleTree.js");
const { hexToBigint, bigintToHex } = require("./utils/bigint.js");

////////////////////////////// MAIN ///////////////////////////////////////////
// forge-ffi-scripts/update.js 0x03 0x03 0x087ae54410521f087a91019b67e454920
// forge-ffi-scripts/update.js 0x0b3 0x0b3 0x075ef19b72f2af417e241fa1583e26ee9


async function main() {
  const inputs = process.argv.slice(2, process.argv.length);
  const commitIndex = parseInt(inputs[0],16);
  const hashesLength = parseInt(inputs[1],16);
  const newRand = hexToBigint(inputs[2]);
  const output = await update(commitIndex,hashesLength,newRand);
  // 6. Return abi encoded witness
  const witness = ethers.utils.defaultAbiCoder.encode(
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "uint[]"],
    [
      output.pA,
      output.pB,
      output.pC,
      [
      bigintToHex(output.lastRoot),
      bigintToHex(output.newRoot),
      bigintToHex(output.index),
      bigintToHex(output.newRand),
      ...output.hashes.map((x) => bigintToHex(x))
      ]
    ]
  );
  return witness;
}


main()
  .then((wtns) => {
    process.stdout.write(wtns);
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
