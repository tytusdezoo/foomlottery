const circomlibjs = require("circomlibjs");
const { MerkleTree } = require("fixed-merkle-tree");

const { leBufferToBigint, hexToBigint, bigintToHex } = require("./bigint.js");
const { openSync, readFileSync, closeSync, existsSync } = require("fs");
const sprintfjs = require('sprintf-js');
const zlib = require('zlib');
// Constants from MerkleTreeWithHistory.sol
const MERKLE_TREE_HEIGHT = 32;

const zeros = [
  "0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0",
  "0x0e5c230fa94b937789a1980f91b9de6233a7d0315f037c7d4917cba089e0042a",
  "0x255da7d5316310ad81de31bfd5b8272b30ce70c742685ac9696446f618399317",
  "0x1dd4b847fd5bdd5d53a661d8268eb5dd6629669922e8a0dcbbeedc8d6a966aaf"
];

function getLines(path){
  let fileold;
  let textold;
  try {
    if(existsSync(path+".gz")){
      fileold = openSync(path+".gz", "r"); // decompress the file
      textold = zlib.gunzipSync(readFileSync(fileold)).toString();
    } else {
      fileold = openSync(path, "r");
      textold = readFileSync(fileold, "utf8");
    }
    closeSync(fileold);
  } catch(e) {
    return [];
  }
  if(textold.length==0){
    return [];
  }
  // remove empty lines
  return textold.split("\n").filter((line) => line.trim() !== "");
}

function readLast(){
  const lines = getLines("www/last.csv");
  const [nextIndex,blockNumber,lastRoot,lastLeaf] = lines[0].split(',');
  return [parseInt(nextIndex,16), parseInt(blockNumber,16), hexToBigint(lastRoot), hexToBigint(lastLeaf)];
}

function getIndexRand(hashstr,betIndex) {
  const path = sprintfjs.sprintf("%06x",betIndex>>8);
  const path1 = path.slice(0,2);
  const path2 = path.slice(2,4); 
  const path3 = path.slice(4,6);
  const lines = getLines("www/"+path1+"/"+path2+"/"+path3+".csv");
  //console.log(hashstr);
  for(let i=0;i<lines.length;i++) {
    const [index,skip,hash,myrand] = lines[i].split(',');
    if(hash==hashstr) {
      //console.log(hash);
      const newIndex=(betIndex&0xffffff00) + parseInt(index,16);
      //console.log(newIndex.toString(16),index);
      return [newIndex,hexToBigint(myrand)];
    }
  }
  return [0,0n];
}

function getIndexWaiting(hashstr) {
  const lines = getLines("www/waiting.csv");
  for(let i=0;i<lines.length;i++) {
    const [index,hash] = lines[i].split(',');
    if(hash==hashstr) {
      return [parseInt(index,16),0n];
    }
  }
  return [0,0n];
}

function findBet(inHash,startindex) {
  const [nextIndex,blockNumber,lastRoot,lastLeaf] = readLast();  // add lastLeaf
  const hashstr = bigintToHex(inHash).replace(/^0x0*/, '');
  for(;startindex<nextIndex;startindex+=0xff) {
    [betIndex,betRand] = getIndexRand(hashstr,startindex);
    if(betIndex>0) {
      return [betIndex,betRand];
    }
  }
  return getIndexWaiting(hashstr);
}

function getWaitingList(nextIndex,hashesLength){
  const lines = getLines("www/waiting.csv");
  const hashes = new Array(hashesLength);
  lines.forEach((line) => {
    if (!line) return;  // Skip empty lines
    const [index,hash] = line.split(','); // assume hash in 2nd column in waiting.csv
    const indexnum = parseInt(index,16);
    if(indexnum >= nextIndex && indexnum < nextIndex + hashesLength) {
      hashes[indexnum-nextIndex] = hexToBigint(hash);
    }
  });
  return hashes;
}

function getLeaves(path){
  let lastindex=-1;
  const lines = getLines(path);
  const leaves = lines.map((line) => {
    const [index,hash] = line.split(',');
    const indexnum = parseInt(index,16);
    if(indexnum>lastindex){
      lastindex=indexnum;
    }
    return hexToBigint(hash);
  });
  return [lastindex, leaves];
}

async function getPath(index){
  const path = sprintfjs.sprintf("%08x",index);
  const path1 = path.slice(0,2);
  const path2 = path.slice(2,4); 
  const path3 = path.slice(4,6);
  const path4 = path.slice(6,8);

  const [lastindex1,leaves1] = getLeaves("www/index.csv");
  if(lastindex1<0 && path1!="00"){
    return [];
  }
  const [lastindex2,leaves2] = getLeaves("www/"+path1+"/index.csv");
  if(lastindex2<0 && path2!="00"){
    return [];
  }
  const [lastindex3,leaves3] = getLeaves("www/"+path1+"/"+path2+"/index.csv");
  if(lastindex3<0 && path3!="00"){
    return [];
  }
  const [lastindex4,leaves4] = getLeaves("www/"+path1+"/"+path2+"/"+path3+".csv");
  if(lastindex4<0){
    return [];
  }
  //console.log(index.toString(16),path1,path2,path3,path4);
  //console.log(leaves3.map((x)=>bigintToHex(x)));
  const tree4 = await mimicMerkleTree(hexToBigint(zeros[0]),leaves4,8);
  const root4 = tree4.root;
  const mpath4 = tree4.path(parseInt(path4,16));
  // append root4 to leaves3
  leaves3.push(root4);
  //console.log(leaves3.map((x)=>bigintToHex(x)));
  const tree3 = await mimicMerkleTree(hexToBigint(zeros[1]),leaves3,8);
  const root3 = tree3.root;
  const mpath3 = tree3.path(parseInt(path3,16)); 
  // append root3 to leaves2
  leaves2.push(root3);
  const tree2 = await mimicMerkleTree(hexToBigint(zeros[2]),leaves2,8);
  const root2 = tree2.root;
  const mpath2 = tree2.path(parseInt(path2,16));
  // append root2 to leaves1
  leaves1.push(root2);
  const tree1 = await mimicMerkleTree(hexToBigint(zeros[3]),leaves1,8);
  const newroot = tree1.root;
  const mpath1 = tree1.path(parseInt(path1,16));
  const pathElements = [...mpath4.pathElements, ...mpath3.pathElements, ...mpath2.pathElements, ...mpath1.pathElements];
  return [...pathElements,newroot];
}

async function getNewRoot(lastindex,newLeaves){
  const path = sprintfjs.sprintf("%08x",lastindex-1);
  const path1 = path.slice(0,2);
  const path2 = path.slice(2,4); 
  const path3 = path.slice(4,6);

  const [lastindex1,leaves1] = getLeaves("www/index.csv");
  const [lastindex2,leaves2] = getLeaves("www/"+path1+"/index.csv");
  const [lastindex3,leaves3] = getLeaves("www/"+path1+"/"+path2+"/index.csv");
  const [lastindex4,leaves4] = getLeaves("www/"+path1+"/"+path2+"/"+path3+".csv");

  const roots = new Array(2);
  leaves4.push(...newLeaves);
  if(leaves4.length>256){
    const tree4a = await mimicMerkleTree(hexToBigint(zeros[0]),leaves4.slice(0,256),8);
    roots[0] = tree4a.root;  
    const tree4b = await mimicMerkleTree(hexToBigint(zeros[0]),leaves4.slice(256,leaves4.length),8);
    roots[1] = tree4b.root;  
  } else {
    const tree4a = await mimicMerkleTree(hexToBigint(zeros[0]),leaves4,8);
    roots[0] = tree4a.root;
    roots[1] = hexToBigint(zeros[1]);
  }
  leaves3.push(...roots);
  if(leaves3.length>256){
    const tree3a = await mimicMerkleTree(hexToBigint(zeros[1]),leaves3.slice(0,256),8);
    roots[0] = tree3a.root;  
    const tree3b = await mimicMerkleTree(hexToBigint(zeros[1]),leaves3.slice(256,leaves3.length),8);
    roots[1] = tree3b.root;  
  } else {
    const tree3a = await mimicMerkleTree(hexToBigint(zeros[1]),leaves3,8);
    roots[0] = tree3a.root;
    roots[1] = hexToBigint(zeros[2]);
  }
  leaves2.push(...roots);
  if(leaves2.length>256){
    const tree2a = await mimicMerkleTree(hexToBigint(zeros[2]),leaves2.slice(0,256),8);
    roots[0] = tree2a.root;  
    const tree2b = await mimicMerkleTree(hexToBigint(zeros[2]),leaves2.slice(256,leaves2.length),8);
    roots[1] = tree2b.root;  
  } else {
    const tree2a = await mimicMerkleTree(hexToBigint(zeros[2]),leaves2,8);
    roots[0] = tree2a.root;
    roots[1] = hexToBigint(zeros[3]);
  }
  leaves1.push(...roots);
  if(leaves1.length>256){
    leaves1.pop();
  }
  const tree1 = await mimicMerkleTree(hexToBigint(zeros[3]),leaves1,8);
  const newRoot = tree1.root;
  return newRoot;
}

async function mimicMerkleTree(zero,leaves = [],hight=MERKLE_TREE_HEIGHT) {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  //const leaf = (zero==0n)?16660660614175348086322821347366010925591495133565739687589833680199500683712n:zero;
  const mimcspongeMultiHash = (left, right) =>
    leBufferToBigint(
      mimcsponge.F.fromMontgomery(mimcsponge.multiHash([left, right]))
    );
  return new MerkleTree(hight, leaves, {
    hashFunction: mimcspongeMultiHash,
    zeroElement: zero,
  });
}

module.exports = {
  mimicMerkleTree,
  readLast,
  getLeaves,
  getPath,
  getIndexWaiting,
  getIndexRand,
  findBet,
  getNewRoot,
  getWaitingList,
  getLines
};
