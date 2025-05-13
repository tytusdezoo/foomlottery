#!/usr/bin/node

const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, } = require("./utils/bigint.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);

  const secret = hexToBigint(inputs[0])>>8n;
  const hash = hexToBigint(inputs[1]);

  const input = {
    // Public inputs
    inHash: hash,
    recipient: hexToBigint(inputs[2]),
    relayer: hexToBigint(inputs[3]),
    fee: BigInt(inputs[4]),
    refund: BigInt(inputs[5]),
    // Private inputs
    secret: secret
  };

  // 5. Create groth16 proof for witness
  const { proof } = await snarkjs.groth16.fullProve(
    input,
    path.join(__dirname, "../circuit_artifacts/cancelbet_js/cancelbet.wasm"),
    path.join(__dirname, "../circuit_artifacts/cancelbet_final.zkey")
  );

  const pA = proof.pi_a.slice(0, 2);
  const pB = proof.pi_b.slice(0, 2);
  const pC = proof.pi_c.slice(0, 2);

  // 6. Return abi encoded witness
  const witness = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "uint", "uint"],
    [
      pA,
      // Swap x coordinates: this is for proof verification with the Solidity precompile for EC Pairings, and not required
      // for verification with e.g. snarkJS.
      [
        [pB[0][1], pB[0][0]],
        [pB[1][1], pB[1][0]],
      ],
      pC,
      bigintToHex(hash),
      bigintToHex(secret)
    ]
  );

//console.log(bigintToHex(nullifierHash),"nullifierHash");
//console.log(bigintToHex(rew1),"rew1");
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
