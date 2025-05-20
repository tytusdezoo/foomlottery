const circomlibjs = require("circomlibjs");
const { MerkleTree } = require("fixed-merkle-tree");

const { leBufferToBigint, hexToBigint, bigintToHex } = require("./bigint.js");
const { openSync, readFileSync, closeSync } = require("fs");
const sprintfjs = require('sprintf-js');

// Constants from MerkleTreeWithHistory.sol
const MERKLE_TREE_HEIGHT = 32;

const zeros = [
  "0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0",
  "0x0e5c230fa94b937789a1980f91b9de6233a7d0315f037c7d4917cba089e0042a",
  "0x255da7d5316310ad81de31bfd5b8272b30ce70c742685ac9696446f618399317",
  "0x1dd4b847fd5bdd5d53a661d8268eb5dd6629669922e8a0dcbbeedc8d6a966aaf"
];

function readLast(){
  try {
    const fileold = openSync("www/last.csv", "r");
    const textold = readFileSync(fileold, "utf8");
    closeSync(fileold);
    const [index,blocknumber,hash] = textold.split(',');
    return [parseInt(index,16), hexToBigint(hash)];
  } catch(e) {
    return [0,0n];
  }
}
function getIndex(inHash) {
  const hashstr = bigintToHex(inHash).replace(/^0x0*/, '');
  //console.log(hashstr);
  const fileold = openSync("www/waiting.csv", "r");
  const textold = readFileSync(fileold, "utf8");
  closeSync(fileold);
  const lines = textold.split("\n");
  for(let i=0;i<lines.length;i++) {
    const [index,hash] = lines[i].split(',');
    if(hash==hashstr) {
      return parseInt(index,16);
    }
  }
  return 0;
}
function getLeaves(path){
  const fileold = openSync(path, "r");
  const textold = readFileSync(fileold, "utf8");
  closeSync(fileold);
  if(textold.length==0){
    return [-1,[]];
  }
  const lines = textold.split('\n');
  // remove last empty line
  lines.pop();
  let lastindex=-1;
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
  const tree4 = await mimicMerkleTree(hexToBigint(zeros[0]),leaves4,8);
  const root4 = tree4.root;
  const mpath4 = tree4.path(parseInt(path4,16));
  // append root4 to leaves3
  leaves3.push(root4);
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
function getIndexRand(hashstr,startindex) {
  const path = sprintfjs.sprintf("%06x",startindex>>8);
  const path1 = path.slice(0,2);
  const path2 = path.slice(2,4); 
  const path3 = path.slice(4,6);
    //console.log(hashstr);
  let fileold;
  try {
    fileold = openSync("www/"+path1+"/"+path2+"/"+path3+".csv", "r");
  } catch(e) {
    return [-1,BigInt(0)];
  }
  const textold = readFileSync(fileold, "utf8");
  closeSync(fileold);
  const lines = textold.split("\n");
  for(let i=0;i<lines.length;i++) {
    const [index,skip,hash,myrand] = lines[i].split(',');
    if(hash==hashstr) {
      return [parseInt(index,16),hexToBigint(myrand)];
    }
  }
  return [-1,BigInt(0)];
}

function findIndex(inHash,startindex) { // TODO ... look also in waiting list
  const hashstr = bigintToHex(inHash).replace(/^0x0*/, '');
  let index=0;
  while(index>=0) {
    [index,myrand] = getIndexRand(hashstr,startindex);
    if(index>0) {
      return [index,myrand];
    }
    startindex += 0xff;
  }
  return [0,0];
}

// Creates a fixed height merkle-tree with MiMC hash function (just like MerkleTreeWithHistory.sol)
async function mimicMerkleTree(zero,leaves = [],hight=MERKLE_TREE_HEIGHT) {
  //const pedersen = await circomlibjs.buildPedersenHash(); //TODO, not needed, fromMontgomery is in mimc
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const leaf = (zero==0n)?16660660614175348086322821347366010925591495133565739687589833680199500683712n:zero;
  //console.log(hight);
  const mimcspongeMultiHash = (left, right) =>
    leBufferToBigint(
      //pedersen.babyJub.F.fromMontgomery(mimcsponge.multiHash([left, right]))
      mimcsponge.F.fromMontgomery(mimcsponge.multiHash([left, right]))
    );

  return new MerkleTree(hight, leaves, {
    hashFunction: mimcspongeMultiHash,
    zeroElement: leaf,
  });
}

module.exports = {
  mimicMerkleTree,
  readLast,
  getLeaves,
  getPath,
  getIndex,
  getIndexRand,
  findIndex,
};
