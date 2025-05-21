#!/usr/bin/node

const { bigintToHex, hexToBigint, leBufferToBigint } = require("./utils/bigint.js");
const circomlibjs = require("circomlibjs");
const sprintfjs = require('sprintf-js');
const { mkdirSync, writeFileSync, existsSync } = require('fs');
const { execSync } = require('child_process');
const { mimicMerkleTree, getWaitingList, readLast, getNewRoot, getLines } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////

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
  writeFileSync("www/last.csv", sprintfjs.sprintf("%x,%x,%s,%s\n",nextIndex,blockNumber,no0x(bigintToHex(lastRoot)),no0x(bigintToHex(lastLeaf))));
}

async function computeRoot(path,zero) {
  const hashes = new Array(256);
  // leave if file does not exists or is gzipped
  let needfix=0;
  const leafs = getLines(path);
  for(let i=0;i<leafs.length;i++) {
    const [numStr, leafStr] = leafs[i].split(',');
    const num = parseInt(numStr, 16);
    const leaf = hexToBigint(leafStr);    
    hashes[num] = leaf;
    if(num!=i){
      needfix++;
    }
  }
  if(needfix>0){
    writeFileSync("www/fix.csv", sprintfjs.sprintf("%s\n",path), { flag: 'a' }); // TODO, write block number too
  } else {
    execSync("gzip -9 "+path);
  }
  const tree = await mimicMerkleTree(zeros[zero],hashes,8);
  return tree.root;
}

function cleanwaiting(nextIndex) {
  const lines = getLines("www/waiting.csv");
  let textnew='';
  for(let i=0;i<lines.length;i++) {
    const [index] = lines[i].split(',');
    const indexnum = parseInt(index,16);
    if(indexnum>=nextIndex) {
      textnew+=lines[i]+"\n";
    }
  }
  writeFileSync("www/waiting.csv", textnew);
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
  writeFileSync("www/"+path1+"/"+path2+"/"+path3+".csv", text, { flag: 'a' });
  if(hash) {
    const root = await computeRoot("www/"+path1+"/"+path2+"/"+path3+".csv",0);
    writeFileSync("www/"+path1+"/"+path2+"/index.csv", sprintfjs.sprintf("%s,%s\n",path3,no0x(bigintToHex(root))), { flag: 'a' });
    if(path3=="ff"){
      const root = await computeRoot("www/"+path1+"/"+path2+"/index.csv",1);
      writeFileSync("www/"+path1+"/index.csv", sprintfjs.sprintf("%s,%s\n",path2,no0x(bigintToHex(root))), { flag: 'a' });
      if(path2=="ff"){
        const root = await computeRoot("www/"+path1+"/index.csv",2);
        writeFileSync("www/index.csv", sprintfjs.sprintf("%s,%s\n",path1,no0x(bigintToHex(root))), { flag: 'a' });
      }
    }
  }
}

async function main() { // TODO: test if update is correct
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const inputs = process.argv.slice(2, process.argv.length);

  const newIndex = parseInt(inputs[0],16);
  const newRand = hexToBigint(inputs[1]);
  const newRoot = hexToBigint(inputs[2]);
  const blockNumber = parseInt(inputs[3],16);

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
  writeLast(nextIndex+commitIndex,blockNumber,newRoot,newLeaves[commitIndex-1]);
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
