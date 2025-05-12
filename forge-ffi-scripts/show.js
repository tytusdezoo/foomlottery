#!/usr/bin/node

const path = require("path");
const snarkjs = require("snarkjs");
const circomlibjs = require("circomlibjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBigintToBuffer, leBufferToBigint } = require("./utils/bigint.js");
const { mimicMerkleTree } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  console.log(21888242871839275222246405745257275088548364400416034343698204186575808495617n,"max");
  // FOOM: 0x4a302ef755ccfe9e93c776ac80fd096a6d5c52c50e578294d145994d13cbfbd7
  // foom: 0x00ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae52 <-- use this !!!
  const foom = hexToBigint(ethers.keccak256(ethers.toUtf8Bytes("foom")));
  const zero = leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([foom, 0])));
  const one = leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([1, 0xf+1]))); // rand = 0
  console.log(foom.toString(),"foom bigint");
  console.log(zero.toString(),"mimcsponge([foom hex,0]) bigint"); // 0x16d18e1425b426e92d3d897958aabf099087b2401bfed53290f5a81fe73c69a5
  console.log(one.toString(),"mimcsponge([1,0xf+1]) bigint"); // 0x16d18e1425b426e92d3d897958aabf099087b2401bfed53290f5a81fe73c69a5
  console.log(bigintToHex(foom),"foom hex");
  //const zero = leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([foom, 0])));
  //const zero = leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([0x4a302ef755ccfe9e93c776ac80fd096a6d5c52c50e578294d145994d13cbfbd7, 0])));
  console.log(bigintToHex(zero),"mimcsponge([foom hex,0]) hex"); // 0x16d18e1425b426e92d3d897958aabf099087b2401bfed53290f5a81fe73c69a5

  const inputs = process.argv.slice(2, process.argv.length);
  const leaves = inputs.slice(0, inputs.length).map((l) => hexToBigint(l));

  const tree = await mimicMerkleTree(leaves);
  const path = tree.path(0);
  let i=0;
  for(;i<32;i++){
    console.log('"',bigintToHex(path.pathElements[i]),'",//',i);}
  console.log('"',bigintToHex(path.pathRoot),'",// ROOT'); // 0x2753cfd5199dc55cf85933769e95affd5b112737e3b97540c74477322402b407
  for(i=0;i<32;i++){
    console.log('"',path.pathElements[i].toString(),'",//',i);}
  console.log('"',path.pathRoot.toString(),'",// ROOT'); // 0x2753cfd5199dc55cf85933769e95affd5b112737e3b97540c74477322402b407

  const output = {
    pathElements: path.pathElements.map((x) => x.toString()),
    root: path.pathRoot,
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
