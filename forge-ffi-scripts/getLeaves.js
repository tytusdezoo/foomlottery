#!/usr/bin/node

const { ethers } = require("ethers");
const { bigintToHex, hexToBigint, leBufferToBigint } = require("./utils/bigint.js");
const circomlibjs = require("circomlibjs");
const sprintf = require('sprintf-js').sprintf;
const { mkdirSync, openSync, writeFileSync } = require('fs');

////////////////////////////// MAIN ///////////////////////////////////////////

function appendtofile(pathlast,text) {
  const path = sprintf("%06x",pathlast);
  const path1 = path.slice(0,2);
  const path2 = path.slice(2,4); 
  const path3 = path.slice(4,6);
  mkdirSync("www/"+path1+"/"+path2, { recursive: true });
  const file = openSync("www/"+path1+"/"+path2+"/"+path3+".csv", "a");
  writeFileSync(file, text);
}

async function main() {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const inputs = process.argv.slice(2, process.argv.length);
  const index = parseInt(inputs[0], 16);
  const newRand = hexToBigint(inputs[1]);
  const newLeaves = inputs.slice(2,inputs.length).map((h,j) => leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([h,newRand,BigInt(index)+BigInt(j)]))));

  if(newLeaves.length==0) {
    return;
  }
  let pathlast=index>>8;
  let text='';
  for (let i=0;i<newLeaves.length;i++) {
    const pathnew = (index+i)>>8;
    if(pathnew!=pathlast) {
      appendtofile(pathlast,text);
      text='';
      pathlast=pathnew;
    }
    text+=sprintf("0x%x,%s,%s,%s\n",index+i,inputs[i],inputs[1],bigintToHex(newLeaves[i]));
  }
  appendtofile(pathlast,text);

  //fs.writeFileSync(path.join(__dirname, '../tmp/update'+inputs.length+'_leaves.csv'), newLeaves.join(','));

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
