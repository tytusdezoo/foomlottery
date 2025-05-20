#!/usr/bin/node

const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBigintToBuffer } = require("./utils/bigint.js");
const { pedersenHash } = require("./utils/pedersen.js");
const { openSync, readFileSync, closeSync } = require("fs");

////////////////////////////// MAIN ///////////////////////////////////////////

function getIndex(inHash) {
  const hashstr = bigintToHex(inHash).replace(/^0x0*/, '');
  //console.log(hashstr);
  const fileold = openSync("www/waiting.csv", "r");
  const textold = readFileSync(fileold, "utf8");
  closeSync(fileold);
  const lines = textold.split("\n");
  for(let i=0;i<lines.length;i++) {
    const [index,hash] = lines[i].split(',');
    if(hash==hashstr) {
      return parseInt(index,16);
    }
  }
  return 0;
}

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);
  const secret_power = hexToBigint(inputs[0]); // TODO: compute hash and read from www
  const secret = secret_power>>8n;
  const power = secret_power & 0x1fn;
  const hash = await pedersenHash(leBigintToBuffer(secret, 31));
  const hash_power1 = hash + power + 1n;
  //const inHash = hexToBigint(inputs[1]);
  const index = getIndex(hash_power1);
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
      index
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
