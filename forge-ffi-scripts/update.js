#!/usr/bin/node
const { execSync } = require('child_process');
const fs = require("fs");
const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBufferToBigint } = require("./utils/bigint.js");
const { getNewRoot, getWaitingList, readLast, getLastPath } = require("./utils/mimcMerkleTree.js");
const circomlibjs = require("circomlibjs");
////////////////////////////// MAIN ///////////////////////////////////////////
// ./forge-ffi-scripts/update.js 0x0000000000000000000000000000000000000000000000000000000000000001 0x000000000000000000000000000000009691a9866228f0e680fe3c605b14a165 0x0000000000000000000000000000000000000000000000000000000000000000 0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0
// forge-ffi-scripts/update.js 1 0x0000000000000000000000000000000007a723530a3ee4727fca6baed148b971 0x26f89aa76d0adcac0bf2c4631dc404ca4056f72d91119df55aea4f9e1f5831ab 0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0


async function main() {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const inputs = process.argv.slice(2, process.argv.length);

  const commitIndex = parseInt(inputs[0],16);
  const hashesLength = parseInt(inputs[1],16);
  const newRand = hexToBigint(inputs[2]);

  const [nextIndex,blockNumber,lastRoot,lastLeaf] = readLast();  // add lastLeaf
  const newHashes = getWaitingList(nextIndex,commitIndex);
  const newLeaves = newHashes.slice(0, commitIndex).map((h,j) => leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([h,newRand,BigInt(nextIndex)+BigInt(j)]))));
  const newRoot = await getNewRoot(nextIndex,newLeaves);
  const hashes = new Array(hashesLength).fill(null).map((x,j) => (j<commitIndex?newHashes[j]:0n));

  const pathElements = await getLastPath(nextIndex-1);

  const input = {
    // Public inputs
    oldRoot: lastRoot,
    newRoot: newRoot,
    index: nextIndex-1,
    newRand: newRand,
    newhashes: hashes,
    // Private inputs
    oldLeaf: lastLeaf,
    pathElements: pathElements.slice(0,32),
  };

  // Write input to input.json
  BigInt.prototype.toJSON = function () { return this.toString(); };
  fs.writeFileSync(path.join(__dirname, '../groth16/update'+hashesLength+'_input.json'), JSON.stringify(input, null, 2));
  //console.log(JSON.stringify(input));

  let proof;
  if(fs.existsSync(path.join(__dirname, '../groth16/prover'))){
    // 5. Create groth16 proof for witness with rapidsnark
    let stdout = execSync("cd "+__dirname+"/../groth16 && "+
      "./update"+hashesLength+" update"+hashesLength+"_input.json update"+hashesLength+"_output.wtns && "+
      "./prover update"+hashesLength+"_final.zkey update"+hashesLength+"_output.wtns update"+hashesLength+"_proof.json "+
      "update"+hashesLength+"_public.json && "+
      "sed -i 's/}.*/}/g' update"+hashesLength+"_proof.json && "+
      "sed -i 's/].*/]/g' update"+hashesLength+"_public.json" );
    // read proof.json and parse to json object
    proof = JSON.parse(fs.readFileSync(path.join(__dirname, '../groth16/update'+hashesLength+'_proof.json'), 'utf8'));
  } else {
  // 5. Create groth16 proof for witness with snarkjs
    proof = await snarkjs.groth16.fullProve(input,
      path.join(__dirname, "../groth16/update"+hashesLength+".wasm"),
      path.join(__dirname, "../groth16/update"+hashesLength+"_final.zkey")
    );
  }

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
      bigintToHex(lastRoot),
      bigintToHex(newRoot),
      bigintToHex(nextIndex-1),
      bigintToHex(newRand),
      ...hashes.map((x) => bigintToHex(x))
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
