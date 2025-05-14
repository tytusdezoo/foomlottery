#!/usr/bin/node

const fs = require("fs");
const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBigintToBuffer, reverseBits, } = require("./utils/bigint.js");
const { mimicMerkleTree } = require("./utils/mimcMerkleTree.js");
const { mimcsponge3 } = require("./utils/mimcsponge.js");

////////////////////////////// MAIN ///////////////////////////////////////////
//test: betsUpdate = 8;
// ./forge-ffi-scripts/update.js 0 1 0x00ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae52 1 2 3 4 5 6 7 0x16d18e1425b426e92d3d897958aabf099087b2401bfed53290f5a81fe73c69a5
// ./forge-ffi-scripts/update.js 0 0 0x00ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae52 0 0 0 0 0 0 0 0x16d18e1425b426e92d3d897958aabf099087b2401bfed53290f5a81fe73c69a5
//real	0m14.653s
//user	1m35.988s
//sys	0m4.841s
// ./forge-ffi-scripts/update.js 0 1 0x00ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae52 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 0x16d18e1425b426e92d3d897958aabf099087b2401bfed53290f5a81fe73c69a5
//real	0m41.248s
//user	4m23.454s
//sys	0m14.194s

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);
  //const betsUpdate = 8;
  const betsUpdate = 22;

  // 1. Get nullifier and secret
  const oldRand = hexToBigint(inputs[0]);
  const newRand = hexToBigint(inputs[1]);
  const newHashes = inputs.slice(2, 2+betsUpdate).map((l) => hexToBigint(l));
  const oldLeaves = inputs.slice(2+betsUpdate, inputs.length).map((l) => hexToBigint(l));
  let i=1;
  for(;i<betsUpdate;i++){
    if(newHashes[i]==0){
      break;}}
  const newLeaves = await Promise.all(newHashes.slice(1, i).map(async (h,j) => await mimcsponge3(h,newRand,BigInt(oldLeaves.length)+BigInt(j))));
  const tree = await mimicMerkleTree(0n,oldLeaves);
  const oldProof = tree.path(oldLeaves.length-1)
//console.log(oldLeaves[0],"leaf");
//console.log(oldLeaves.length-1,"index");
//console.log(oldProof.pathRoot,"root");
//console.log(bigintToHex(oldProof.pathRoot),"root hex");
//return;
  tree.bulkInsert(newLeaves);
  const newProof = tree.path(oldLeaves.length+newLeaves.length-1)

  // 4. Format witness input to exactly match circuit expectations
  const input = {
    // Public inputs
    oldRoot: oldProof.pathRoot,
    newRoot: newProof.pathRoot,
    index: oldLeaves.length-1,
    newRand: newRand,
    newhashes: newHashes.map((x) => x.toString()),
    // Private inputs
    oldRand: oldRand,
    pathElements: oldProof.pathElements.map((x) => x.toString()),
  };

  // Write input to input.json
  // only for debugging
  BigInt.prototype.toJSON = function () { return this.toString(); };
  fs.writeFileSync(path.join(__dirname, '../tmp/update_input.json'), JSON.stringify(input, null, 2));
  //console.log(JSON.stringify(input));

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
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "uint", "uint", "uint", "uint", "uint["+betsUpdate+"]"],
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
      //bigintToHex(oldRand),
      bigintToHex(newRand),
      newHashes.map((x) => bigintToHex(x)),
    ]
  );
  // 4. Format witness input to exactly match circuit expectations
  // only for debugging
  const zkpublic = [
    (oldProof.pathRoot).toString(),
    (newProof.pathRoot).toString(),
    (oldLeaves.length-1).toString(),
    //(oldRand).toString(),
    (newRand).toString(),
    ...newHashes.map((x) => x.toString()), // spread the array into individual elements
  ];
  fs.writeFileSync(path.join(__dirname, '../tmp/update_public.json'), JSON.stringify(zkpublic, null, 2));
  // only for debugging
  const zkproof = {
    pi_a: [pA[0],pA[1],1],
    pi_b: [[pB[0][0],pB[0][1]],[pB[1][0],pB[1][1]],[1,0]],
    pi_c: [pC[0],pC[1],1],
    protocol: "groth16",
    curve: "bn128",
  };  
  fs.writeFileSync(path.join(__dirname, '../tmp/update_proof.json'), JSON.stringify(zkproof, null, 2));

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
