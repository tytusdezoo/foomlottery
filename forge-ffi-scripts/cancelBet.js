#!/usr/bin/node

const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBigintToBuffer } = require("./utils/bigint.js");
const { pedersenHash } = require("./utils/pedersen.js");
const { openSync, readFileSync, closeSync } = require("fs");
const { mimicMerkleTree, readLast, getLeaves, getPath, getIndex } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);
  const secret_power = hexToBigint(inputs[0]); // TODO: compute hash and read from www
  const secret = secret_power>>8n;
  const power = secret_power & 0x1fn;
  const hash = await pedersenHash(leBigintToBuffer(secret, 31));
  const hash_power1 = hash + power + 1n;
  const startIndex = parseInt(inputs[1].replace(/^0x0*/, ''),16); // could be int instead of hex later

  const betIndex = getIndex(hash_power1); // use startIndex !!! TODO: refactor
  const input = {
    inHash: hash,
    secret: secret
  };
  const { proof } = await snarkjs.groth16.fullProve(
    input,
    path.join(__dirname, "../groth16/cancelbet.wasm"),
    path.join(__dirname, "../groth16/cancelbet_final.zkey")
  );
  const pA = proof.pi_a.slice(0, 2);
  const pB = proof.pi_b.slice(0, 2);
  const pC = proof.pi_c.slice(0, 2);
  const witness = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "uint[1]", "uint"], // send index back
    [ pA,
      [ // swap
        [pB[0][1], pB[0][0]],
        [pB[1][1], pB[1][0]],
      ],
      pC,
      [bigintToHex(hash)],
      betIndex
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
