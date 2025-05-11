#!/usr/bin/node

const path = require("path");
const snarkjs = require("snarkjs");
const circomlibjs = require("circomlibjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBigintToBuffer, leBufferToBigint } = require("./utils/bigint.js");
const { mimicMerkleTree } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const foom = ethers.keccak256(ethers.toUtf8Bytes("FOOM"));
  console.log(foom.toString()); // 0x4a302ef755ccfe9e93c776ac80fd096a6d5c52c50e578294d145994d13cbfbd7
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const zero = leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([foom, 0])));
  console.log(bigintToHex(zero)); // 0x202a8f96045740e4004986fd2b650cf51b0cc148fb60f01312e628237deef281

  const inputs = process.argv.slice(2, process.argv.length);
  const leaves = inputs.slice(0, inputs.length).map((l) => hexToBigint(l));

  const tree = await mimicMerkleTree(leaves);
  const proof = tree.path(0);
  let i=0;
  for(;i<32;i++){
    console.log(bigintToHex(proof.pathElements[i]),i);}
  console.log(bigintToHex(proof.pathRoot));

  const output = {
    root: proof.pathRoot,
    pathElements: proof.pathElements.map((x) => x.toString()),
  };

//console.log(input);
  return output.toString();
}

main()
  .then((output) => {
    //process.stdout.write(output);
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
