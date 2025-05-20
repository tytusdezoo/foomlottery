#!/usr/bin/node

const { ethers } = require("ethers");
const { bigintToHex, hexToBigint, leBufferToBigint } = require("./utils/bigint.js");
const circomlibjs = require("circomlibjs");
const sprintfjs = require('sprintf-js');
const { mkdirSync, openSync, writeFileSync, readFileSync, closeSync, existsSync } = require('fs');
const { execSync } = require('child_process');
const { mimicMerkleTree } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////
// const zero08 = hexToBigint("0x0e5c230fa94b937789a1980f91b9de6233a7d0315f037c7d4917cba089e0042a"); needed in withdraw
// const zero16 = hexToBigint("0x255da7d5316310ad81de31bfd5b8272b30ce70c742685ac9696446f618399317"); needed in withdraw

// forge-ffi-scripts/getLeaves.js 1 0x0000000000000000000000000000000007a723530a3ee4727fca6baed148b971 0x1d4a9174860dc2bb70074560843307f625509fa9c8bc88677425d0b0b05c364b

const zeros = [
  "0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0",
  "0x0e5c230fa94b937789a1980f91b9de6233a7d0315f037c7d4917cba089e0042a",
  "0x255da7d5316310ad81de31bfd5b8272b30ce70c742685ac9696446f618399317"
];

function touchfile(path) {
  // use fs.existsSync to check if file exists
  if(!existsSync(path)) {
    writeFileSync(path, '');
  }
}

function no0x(str) {
  return str.replace(/^0x0*/, '');
}

async function computeRoot(path,zero) {
  const hashes = new Array(256);
  const hashfile = openSync(path, "r");
  // leave if file does not exists or is gzipped
  const hashcontent = readFileSync(hashfile, "utf8");
  closeSync(hashfile);
  //split file by lines:
  const leafs = hashcontent.split("\n");
  let needfix=0;
  for(let i=0;i<leafs.length;i++) {
    if (!leafs[i]) continue;  // Skip empty lines
    const [numStr, leafStr] = leafs[i].split(',');
    const num = parseInt(numStr, 16);
    if(num!=i){
      needfix++;
    }
    const leaf = hexToBigint(leafStr);    
    hashes[num] = leaf;
  }
  if(needfix>0){
    const filefix = openSync("www/fix.csv", "a");
    const textfix=sprintfjs.sprintf("%s\n",path); // TODO, write block number too
    writeFileSync(filefix, textfix);
    closeSync(filefix);
  }
  execSync("gzip -9 "+path);

  const tree = await mimicMerkleTree(zeros[zero],hashes,8);
  return tree.root;
}

function cleanwaiting(indexlast) {
  const fileold = openSync("www/waiting.csv", "r");
  const textold = readFileSync(fileold, "utf8");
  closeSync(fileold);
  const lines = textold.split("\n");
  let textnew='';
  for(let i=0;i<lines.length;i++) {
    const [index] = lines[i].split(',');
    const indexnum = parseInt(index,16);
    if(indexnum>=indexlast) {
      textnew+=lines[i]+"\n";
    }
  }
  const file = openSync("www/waiting.csv", "w");
  writeFileSync(file, textnew);
  closeSync(file);
}

async function appendtofile(pathlast,text,hash) {
  // leave if file is gzipped
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
    const root = await computeRoot("www/"+path1+"/"+path2+"/"+path3+".csv",0);
    const file = openSync("www/"+path1+"/"+path2+"/index.csv", "a");
    writeFileSync(file, sprintfjs.sprintf("%s,%s\n",path3,no0x(bigintToHex(root))));
    closeSync(file);
    if(path3=="ff"){
      const root = await computeRoot("www/"+path1+"/"+path2+"/index.csv",1);
      const file = openSync("www/"+path1+"/index.csv", "a");
      writeFileSync(file, sprintfjs.sprintf("%s,%s\n",path2,no0x(bigintToHex(root))));
      closeSync(file);
      if(path2=="ff"){
        const root = await computeRoot("www/"+path1+"/index.csv",2);
        const file = openSync("www/index.csv", "a");
        writeFileSync(file, sprintfjs.sprintf("%s,%s\n",path1,no0x(bigintToHex(root))));
        closeSync(file);
      }
    }
  }
}

//TODO, change format: remove 0x0* from .csv file
async function main() {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const inputs = process.argv.slice(2, process.argv.length);
  const index = parseInt(inputs[0]);
  const blocknumber = parseInt(inputs[1]);
  //const newRoot = hexToBigint(inputs[2]);
  const newRand = hexToBigint(inputs[3]);
  const newLeaves = inputs.slice(4,inputs.length).map((h,j) => leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([h,newRand,BigInt(index)+BigInt(j)]))));
  if(newLeaves.length==0) {
    return;
  }

  let nextindex=0;
  if(index==1){
    mkdirSync("www/00/00", { recursive: true });
    const file = openSync("www/00/00/00.csv", "w");
    const text=sprintfjs.sprintf("%x,%s,%s,%s\n",0,
      "24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0",
      "ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae520","0");
    writeFileSync(file, text);
    closeSync(file);
    const filelast = openSync("www/last.csv", "w");
    const textlast=sprintfjs.sprintf("%x,%x\n",1,blocknumber); // TODO, write block number too
    writeFileSync(filelast, textlast);
    closeSync(filelast);
  } else {
    const filelast = openSync("www/last.csv", "r");
    const textlast=readFileSync(filelast, "utf8");
    closeSync(filelast);
    const [indexlast] = textlast.split(',');
    nextindex=parseInt(indexlast,16);
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
    if(nextindex<=(index+i)) {
      text+=sprintfjs.sprintf("%x,%s,%s,%s\n",(index+i)&0xFF,no0x(bigintToHex(newLeaves[i])),no0x(inputs[4+i]),no0x(inputs[3])); // index, leaf, hash, rand
    }
  }
  await appendtofile(pathlast,text,(index+i)&0xff==0?true:false);
  // write last index to file
  const file = openSync("www/last.csv", "w");
  const textlast=sprintfjs.sprintf("%x,%x,%s\n",index+i,blocknumber,no0x(inputs[2])); // TODO, write block number too
  writeFileSync(file, textlast);
  closeSync(file);

  cleanwaiting(index+i);

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
