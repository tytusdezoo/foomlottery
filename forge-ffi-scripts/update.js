#!/usr/bin/node

const { execSync } = require('child_process');
const fs = require("fs");
const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBufferToBigint } = require("./utils/bigint.js");
const { mimicMerkleTree } = require("./utils/mimcMerkleTree.js");
const circomlibjs = require("circomlibjs");
////////////////////////////// MAIN ///////////////////////////////////////////
// ./forge-ffi-scripts/update.js 0x0000000000000000000000000000000000000000000000000000000000000001 0x000000000000000000000000000000009691a9866228f0e680fe3c605b14a165 0x0000000000000000000000000000000000000000000000000000000000000000 0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);
  const mimcsponge = await circomlibjs.buildMimcSponge();

  // 1. Get nullifier and secret
  const hashesLength = parseInt(inputs[0]);
  const newRand = hexToBigint(inputs[1]);
  const newHashes = inputs.slice(2, 2+hashesLength).map((l) => hexToBigint(l));
  const oldLeaves = inputs.slice(2+hashesLength, inputs.length).map((l) => hexToBigint(l));
  const tree = await mimicMerkleTree(0n,oldLeaves);
  const oldProof = tree.path(oldLeaves.length-1)
  let i=0;
  for(;i<hashesLength;i++){
    if(newHashes[i]==0){
      break;}}
  
  const newLeaves = newHashes.slice(0, i).map((h,j) => leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([h,newRand,BigInt(oldLeaves.length)+BigInt(j)]))));

  tree.bulkInsert(newLeaves);
  const newProof = tree.path(oldLeaves.length-1+newLeaves.length)

  // 4. Format witness input to exactly match circuit expectations
  const input = {
    // Public inputs
    oldRoot: oldProof.pathRoot,
    newRoot: newProof.pathRoot,
    index: oldLeaves.length-1,
    newRand: newRand,
    newhashes: newHashes.map((x) => x.toString()),
    // Private inputs
    oldLeaf: oldLeaves[oldLeaves.length-1].toString(),
    pathElements: oldProof.pathElements.map((x) => x.toString()),
  };

  // Write input to input.json
  // only for debugging
  BigInt.prototype.toJSON = function () { return this.toString(); };
  fs.writeFileSync(path.join(__dirname, '../groth16/update'+hashesLength+'_input.json'), JSON.stringify(input, null, 2));
  //console.log(JSON.stringify(input));

  // console.log current working directory
  let stdout = execSync("cd "+__dirname+"/../groth16 && "+
    "./update"+hashesLength+" update"+hashesLength+"_input.json update"+hashesLength+"_output.wnts && "+
    "./prover update"+hashesLength+"_final.zkey update"+hashesLength+"_output.wnts update"+hashesLength+"_proof.json "+
    "update"+hashesLength+"_public.json && "+
    "sed -i 's/}.*/}/g' update"+hashesLength+"_proof.json && "+
    "sed -i 's/].*/]/g' update"+hashesLength+"_public.json" );
  // read proof.json and parse to json object
  const proof = JSON.parse(fs.readFileSync(path.join(__dirname, '../groth16/update'+hashesLength+'_proof.json'), 'utf8'));

  // 5. Create groth16 proof for witness
  /*const { proof } = await snarkjs.groth16.fullProve(
    input,
    path.join(__dirname, "../groth16/update"+hashesLength+".wasm"),
    path.join(__dirname, "../groth16/update"+hashesLength+"_final.zkey")
  );*/

  const pA = proof.pi_a.slice(0, 2);
  const pB = proof.pi_b.slice(0, 2);
  const pC = proof.pi_c.slice(0, 2);

  // 6. Return abi encoded witness
  const witness = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "uint[]"],
    [
      pA,
      // Swap x coordinates: this is for proof verification with the Solidity precompile for EC Pairings, and not required
      // for verification with e.g. snarkJS.
      [
        [pB[0][1], pB[0][0]],
        [pB[1][1], pB[1][0]],
      ],
      pC,
      [
      bigintToHex(oldProof.pathRoot),
      bigintToHex(newProof.pathRoot),
      bigintToHex(oldLeaves.length-1),
      bigintToHex(newRand),
      ...newHashes.map((x) => bigintToHex(x))
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
