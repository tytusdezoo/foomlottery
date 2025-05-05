#!/usr/bin/node

const { ethers } = require("ethers");
const { pedersenHash } = require("./utils/pedersen.js");
const { rbigint, bigintToHex, leBigintToBuffer, hexToBigint } = require("./utils/bigint.js");
const { getData } = require("./utils/mask.js");
const { mimcRC } = require("./utils/mimcsponge.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);

  // 1. Get secret and ticket and mask
  const data = getData(hexToBigint(inputs[0]), hexToBigint(inputs[1]), rbigint(31));
  const ticket = data.ticket;
  const secret = data.secret;
  const mask = data.mask;

  // 2. Get hash
  const hash = await pedersenHash(leBigintToBuffer(secret, 31));
  const mimc = await mimcRC(hash, mask);

  // 3. Return abi encoded hash, secret, mask, mimcR, mimcC, ticket
  const res = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint", "uint", "uint", "uint", "uint", "uint"],
    [bigintToHex(hash), bigintToHex(secret), bigintToHex(mask), bigintToHex(mimc.R), bigintToHex(mimc.C), bigintToHex(ticket)]
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
