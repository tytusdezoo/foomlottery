#!/usr/bin/node

const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { mimicMerkleTree, readLast, getLeaves, getPath } = require("./utils/mimcMerkleTree.js");
const { hexToBigint, bigintToHex, leBigintToBuffer, reverseBits, } = require("./utils/bigint.js");
const { openSync, readFileSync, closeSync } = require("fs");
const sprintfjs = require('sprintf-js');
////////////////////////////// MAIN ///////////////////////////////////////////

/*
const zeros = [
  "0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0",
  "0x0e5c230fa94b937789a1980f91b9de6233a7d0315f037c7d4917cba089e0042a",
  "0x255da7d5316310ad81de31bfd5b8272b30ce70c742685ac9696446f618399317",
  "0x1dd4b847fd5bdd5d53a661d8268eb5dd6629669922e8a0dcbbeedc8d6a966aaf"
];
*/

async function main() {
  // read last index from file
  const [lastindex, root] = readLast();
  
  /*
  const [lastindex1,leaves1] = getLeaves("www/index.csv");
  const path1 = sprintfjs.sprintf("%02x",lastindex1+1);
  const [lastindex2,leaves2] = getLeaves("www/"+path1+"/index.csv");
  const path2 = sprintfjs.sprintf("%02x",lastindex2+1);
  const [lastindex3,leaves3] = getLeaves("www/"+path1+"/"+path2+"/index.csv");
  const path3 = sprintfjs.sprintf("%02x",lastindex3+1);
  const [lastindex4,leaves4] = getLeaves("www/"+path1+"/"+path2+"/"+path3+".csv");
  const newindex = (lastindex1+1)*2**24+(lastindex2+1)*2**16+(lastindex3+1)*2**8+lastindex4+1;

  const tree4 = await mimicMerkleTree(hexToBigint(zeros[0]),leaves4,8);
  const root4 = tree4.root;
  const mpath4 = tree4.path(lastindex4);
  // append root4 to leaves3
  leaves3.push(root4);
  const tree3 = await mimicMerkleTree(hexToBigint(zeros[1]),leaves3,8);
  const root3 = tree3.root;
  const mpath3 = tree3.path(lastindex3+1); 
  // append root3 to leaves2
  leaves2.push(root3);
  const tree2 = await mimicMerkleTree(hexToBigint(zeros[2]),leaves2,8);
  const root2 = tree2.root;
  const mpath2 = tree2.path(lastindex2+1);
  // append root2 to leaves1
  leaves1.push(root2);
  const tree1 = await mimicMerkleTree(hexToBigint(zeros[3]),leaves1,8);
  const newroot = tree1.root;
  const mpath1 = tree1.path(lastindex1+1);

  console.log(bigintToHex(lastindex),"old index");
  console.log(bigintToHex(root),"old root");
  console.log(bigintToHex(BigInt(newindex)),"new index");
  console.log(bigintToHex(newroot),"new root");

  // marge pathElements into one array
  const pathElements = [...mpath4.pathElements, ...mpath3.pathElements, ...mpath2.pathElements, ...mpath1.pathElements];
  console.log(pathElements.map((p) => bigintToHex(p)));
  */

  const pathElements2 = await getPath(lastindex-1);
  console.log(pathElements2.map((p) => bigintToHex(p)));

  /*
  const leaves = inputs.slice(8, inputs.length).map((l) => hexToBigint(l));
  const tree = await mimicMerkleTree(0n,leaves);
  const merkleProof = tree.path(Number(index));
  */

  return;
}

main()
  .then((wtns) => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
