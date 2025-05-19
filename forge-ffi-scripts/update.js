#!/usr/bin/node

const fs = require("fs");
const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBigintToBuffer, reverseBits, } = require("./utils/bigint.js");
const { mimicMerkleTree } = require("./utils/mimcMerkleTree.js");
const { mimcsponge3 } = require("./utils/mimcsponge.js");

////////////////////////////// MAIN ///////////////////////////////////////////
// ./forge-ffi-scripts/update.js 0x0000000000000000000000000000000000000000000000000000000000000001 0x000000000000000000000000000000009691a9866228f0e680fe3c605b14a165 0x0000000000000000000000000000000000000000000000000000000000000000 0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);

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
  // TODO: will fail for 100 hashes !!!, need to do this in sync mode
  const newLeaves = await Promise.all(newHashes.slice(0, i).map(async (h,j) => await mimcsponge3(h,newRand,BigInt(oldLeaves.length)+BigInt(j))));
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
  fs.writeFileSync(path.join(__dirname, '../tmp/update'+hashesLength+'_input.json'), JSON.stringify(input, null, 2));
  //console.log(JSON.stringify(input));

// ./update179 input.json output.wtns && ./prover update89_final.zkey output.wtns proof.json public.json

  // 5. Create groth16 proof for witness
  const { proof } = await snarkjs.groth16.fullProve(
    input,
    path.join(__dirname, "../groth16/update"+hashesLength+".wasm"),
    path.join(__dirname, "../groth16/update"+hashesLength+"_final.zkey")
  );

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
  // 4. Format witness input to exactly match circuit expectations
  // only for debugging
  const zkpublic = [
    (oldProof.pathRoot).toString(),
    (newProof.pathRoot).toString(),
    (oldLeaves.length-1).toString(),
    (newRand).toString(),
    ...newHashes.map((x) => x.toString()), // spread the array into individual elements
  ];
  fs.writeFileSync(path.join(__dirname, '../tmp/update'+hashesLength+'_public.json'), JSON.stringify(zkpublic, null, 2));
  // only for debugging
  const zkproof = {
    pi_a: [pA[0],pA[1],1],
    pi_b: [[pB[0][0],pB[0][1]],[pB[1][0],pB[1][1]],[1,0]],
    pi_c: [pC[0],pC[1],1],
    protocol: "groth16",
    curve: "bn128",
  };  
  fs.writeFileSync(path.join(__dirname, '../tmp/update'+hashesLength+'_proof.json'), JSON.stringify(zkproof, null, 2));

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
