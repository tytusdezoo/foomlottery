#!/usr/bin/node

const { ethers } = require("ethers");
const { bigintToHex, hexToBigint, leBufferToBigint } = require("./utils/bigint.js");
const circomlibjs = require("circomlibjs");
const sprintfjs = require('sprintf-js');
const { mkdirSync, openSync, writeFileSync, readFileSync, closeSync, existsSync } = require('fs');
const { execSync } = require('child_process');
const { mimicMerkleTree, getWaitingList, readLast, getNewRoot } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////
// const zero08 = hexToBigint("0x0e5c230fa94b937789a1980f91b9de6233a7d0315f037c7d4917cba089e0042a"); needed in withdraw
// const zero16 = hexToBigint("0x255da7d5316310ad81de31bfd5b8272b30ce70c742685ac9696446f618399317"); needed in withdraw

// forge-ffi-scripts/getLeaves.js 1 0x0000000000000000000000000000000007a723530a3ee4727fca6baed148b971 0x1d4a9174860dc2bb70074560843307f625509fa9c8bc88677425d0b0b05c364b

const zeros = [
  "0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0",
  "0x0e5c230fa94b937789a1980f91b9de6233a7d0315f037c7d4917cba089e0042a",
  "0x255da7d5316310ad81de31bfd5b8272b30ce70c742685ac9696446f618399317",
  "0x1dd4b847fd5bdd5d53a661d8268eb5dd6629669922e8a0dcbbeedc8d6a966aaf"
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

function writeLast(nextIndex,blockNumber,lastRoot,lastLeaf){
  const file = openSync("www/last.csv", "w");
  const textlast=sprintfjs.sprintf("%x,%x,%s,%s\n",nextIndex,blockNumber,no0x(bigintToHex(lastRoot)),no0x(bigintToHex(lastLeaf)));
  writeFileSync(file, textlast);
  closeSync(file);
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

async function main() { // TODO: test if update is correct
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const inputs = process.argv.slice(2, process.argv.length);

  const newIndex = parseInt(inputs[0]);
  const newRand = hexToBigint(inputs[1]);
  const newRoot = hexToBigint(inputs[2]);
  const blockNumber = parseInt(inputs[3]);

  const [nextIndex,lastBlockNumber,lastRoot,lastLeaf] = readLast();  // add lastLeaf
  if(newIndex<=nextIndex){
    return;}
  const commitIndex=newIndex-nextIndex;
  const newHashes = getWaitingList(nextIndex,commitIndex);
  const newLeaves = newHashes.slice(0, commitIndex).map((h,j) => leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([h,newRand,BigInt(nextIndex)+BigInt(j)]))));
  const testRoot = await getNewRoot(nextIndex,newLeaves);
  if(testRoot!=newRoot){
    throw("root mismatch");}

  let pathlast=nextIndex>>8;
  let text='';
  for (let i=0;i<commitIndex;i++) {
    const pathnew = (nextIndex+i)>>8;
    if(pathnew!=pathlast) {
      await appendtofile(pathlast,text,true);
      text='';
      pathlast=pathnew;
    }
    text+=sprintfjs.sprintf("%x,%s,%s,%s\n",(nextIndex+i)&0xFF,no0x(bigintToHex(newLeaves[i])),no0x(bigintToHex(newHashes[i])),no0x(bigintToHex(newRand))); // index, leaf, hash, rand
  }
  await appendtofile(pathlast,text,(nextIndex+commitIndex)&0xff==0?true:false);
  writeLast(nextIndex+commitIndex,blockNumber,no0x(bigintToHex(newRoot)),no0x(bigintToHex(newLeaves[commitIndex-1])));
  cleanwaiting(nextIndex+commitIndex);
}

main()
  .then((res) => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
