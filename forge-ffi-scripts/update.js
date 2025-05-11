#!/usr/bin/node

const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBigintToBuffer, reverseBits, } = require("./utils/bigint.js");
const { mimicMerkleTree } = require("./utils/mimcMerkleTree.js");
const { mimcsponge2 } = require("./utils/mimcsponge.js");

////////////////////////////// MAIN ///////////////////////////////////////////
//test:
//./forge-ffi-scripts/update.js 0 0 0x4a302ef755ccfe9e93c776ac80fd096a6d5c52c50e578294d145994d13cbfbd7 0 0 0 0 0 0 0 0x202a8f96045740e4004986fd2b650cf51b0cc148fb60f01312e628237deef281
//real	0m14.653s
//user	1m35.988s
//sys	0m4.841s

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);
  const betsUpdate = 8;

  // 1. Get nullifier and secret
  const oldRand = hexToBigint(inputs[0]);
  const newRand = hexToBigint(inputs[1]);
  const newHashes = inputs.slice(2, 2+betsUpdate).map((l) => hexToBigint(l));
  const oldLeaves = inputs.slice(2+betsUpdate, inputs.length).map((l) => hexToBigint(l));
  let i=1;
  for(;i<betsUpdate;i++){
    if(newHashes[i]==0){
      break;}}
  const newLeaves = await Promise.all(newHashes.slice(1, i).map(async (h,j) => await mimcsponge2(h,newRand+BigInt(oldLeaves.length)+BigInt(j))));
  const tree = await mimicMerkleTree(oldLeaves);
  const oldProof = tree.path(oldLeaves.length-1)
  tree.bulkInsert(newLeaves);
  const newProof = tree.path(oldLeaves.length+newLeaves.length-1)

  // 4. Format witness input to exactly match circuit expectations
  const input = {
    // Public inputs
    oldRoot: oldProof.pathRoot,
    newRoot: newProof.pathRoot,
    index: oldLeaves.length-1,
    oldRand: oldRand,
    newRand: newRand,
    newhashes: newHashes.map((x) => x.toString()),
    // Private inputs
    pathElements: oldProof.pathElements.map((x) => x.toString()),
  };

//console.log(input);

  // 5. Create groth16 proof for witness
  const { proof } = await snarkjs.groth16.fullProve(
    input,
    path.join(__dirname, "../circuit_artifacts/update_js/update.wasm"),
    path.join(__dirname, "../circuit_artifacts/update_final.zkey")
  );

  const pA = proof.pi_a.slice(0, 2);
  const pB = proof.pi_b.slice(0, 2);
  const pC = proof.pi_c.slice(0, 2);

  // 6. Return abi encoded witness
  const witness = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "uint", "uint", "uint", "uint", "uint", "uint[8]"], // uint[betsUpdate]
    [
      pA,
      // Swap x coordinates: this is for proof verification with the Solidity precompile for EC Pairings, and not required
      // for verification with e.g. snarkJS.
      [
        [pB[0][1], pB[0][0]],
        [pB[1][1], pB[1][0]],
      ],
      pC,
      bigintToHex(oldProof.pathRoot),
      bigintToHex(newProof.pathRoot),
      bigintToHex(oldLeaves.length-1),
      bigintToHex(oldRand),
      bigintToHex(newRand),
      newHashes.map((x) => bigintToHex(x)),
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
