#!/usr/bin/node

const { ethers } = require("ethers");
const { bigintToHex, hexToBigint, leBufferToBigint } = require("./utils/bigint.js");
const circomlibjs = require("circomlibjs");
const sprintfjs = require('sprintf-js');
const { mkdirSync, openSync, writeFileSync, readFileSync, closeSync } = require('fs');
const { mimicMerkleTree } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////
// const zero08 = hexToBigint("0x0e5c230fa94b937789a1980f91b9de6233a7d0315f037c7d4917cba089e0042a"); needed in withdraw
// const zero16 = hexToBigint("0x255da7d5316310ad81de31bfd5b8272b30ce70c742685ac9696446f618399317"); needed in withdraw

function touchfile(path) {
  try {
    openSync(path, 'r');
  } catch (e) {
    writeFileSync(path, '');
  }
}

async function computeRoot(path) {
  const hashes = new Array(256);
  const hashfile = openSync(path, "r");
  const hashcontent = readFileSync(hashfile, "utf8");
  closeSync(hashfile);
  //split file by lines:
  const leafs = hashcontent.split("\n");
  let needfix=0;
  for(let i=0;i<leafs.length;i++) {
    if (!leafs[i]) continue;  // Skip empty lines
    const [numStr, leafStr] = leafs[i].split(',');
    const num = parseInt(numStr.replace('0x', ''), 16);
    if(num!=i){
      needfix++;
    }
    const leaf = hexToBigint(leafStr);    
    hashes[num] = leaf;
  }
  if(needfix>0){
    //TODO: fix the file
  }
  const tree = await mimicMerkleTree(0n,hashes,8);
  //console.log(tree.root.toString());
  return tree.root;
}

async function appendtofile(pathlast,text,hash) {
  const path = sprintfjs.sprintf("%06x",pathlast);
  const path1 = path.slice(0,2);
  const path2 = path.slice(2,4); 
  const path3 = path.slice(4,6);
  mkdirSync("www/"+path1+"/"+path2, { recursive: true });
  if(path3=="00") {
    touchfile("www/"+path1+"/"+path2+"/index.csv");
    if(path2=="00"){
      touchfile("www/"+path1+"/index.csv");
      if(path1=="00") {
        touchfile("www/index.csv");
      }
    }
  }
  const file = openSync("www/"+path1+"/"+path2+"/"+path3+".csv", "a");
  writeFileSync(file, text);
  closeSync(file);
  if(hash) {
    const root = await computeRoot("www/"+path1+"/"+path2+"/"+path3+".csv");
    const file = openSync("www/"+path1+"/"+path2+"/index.csv", "a");
    writeFileSync(file, sprintfjs.sprintf("0x%02x,%s\n",path3,root.toString()));
    closeSync(file);
    if(path3=="ff"){
      const root = await computeRoot("www/"+path1+"/"+path2+"/index.csv");
      const file = openSync("www/"+path1+"/index.csv", "a");
      writeFileSync(file, sprintfjs.sprintf("0x%02x,%s\n",path2,root.toString()));
      closeSync(file);
      if(path2=="ff"){
        const root = await computeRoot("www/"+path1+"/index.csv");
        const file = openSync("www/index.csv", "a");
        writeFileSync(file, sprintfjs.sprintf("0x%02x,%s\n",path1,root.toString()));
        closeSync(file);
      }
    }
  }
}

async function main() {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const inputs = process.argv.slice(2, process.argv.length);
  //const index = parseInt(inputs[0], 16);
  const index = parseInt(inputs[0]);
  const newRand = hexToBigint(inputs[1]);
  const newLeaves = inputs.slice(2,inputs.length).map((h,j) => leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([h,newRand,BigInt(index)+BigInt(j)]))));

  if(index==1){
    mkdirSync("www/00/00", { recursive: true });
    const file = openSync("www/00/00/00.csv", "w");
    const text=sprintfjs.sprintf("0x%x,%s,%s,0x%x\n",0,
      "0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0",
      "0x0ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae520",0);
    writeFileSync(file, text);
    closeSync(file);
  }
  if(newLeaves.length==0) {
    return;
  }
  let pathlast=index>>8;
  let text='';
  let i=0;
  for (;i<newLeaves.length;i++) {
    const pathnew = (index+i)>>8;
    if(pathnew!=pathlast) {
      await appendtofile(pathlast,text,true);
      text='';
      pathlast=pathnew;
    }
    text+=sprintfjs.sprintf("0x%x,%s,%s,%s\n",index+i,bigintToHex(newLeaves[i]),inputs[2+i],inputs[1]);
  }
  await appendtofile(pathlast,text,(index+i)&0xff==0?true:false);

  const res = ethers.AbiCoder.defaultAbiCoder().encode( ["uint[]"], [newLeaves.map((x) => bigintToHex(x))]);
  return res;
}

main()
  .then((res) => {
    process.stdout.write(res);
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
