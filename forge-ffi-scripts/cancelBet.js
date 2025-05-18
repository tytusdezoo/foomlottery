#!/usr/bin/node

const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, } = require("./utils/bigint.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);
  const secret = hexToBigint(inputs[0])>>8n;
  const inHash = hexToBigint(inputs[1]);
  const input = {
    inHash: inHash,
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
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "uint[1]"],
    [ pA,
      [ // swap
        [pB[0][1], pB[0][0]],
        [pB[1][1], pB[1][0]],
      ],
      pC,
      [bigintToHex(inHash)]
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
