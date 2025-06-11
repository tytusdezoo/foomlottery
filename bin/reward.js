#!/usr/bin/node
const dotenv = require("dotenv");
const { ethers } = require("ethers");
const fs = require("fs");
const { hexToBigint, leBigintToBuffer, leBufferToBigint } = require("./utils/bigint.js");
const { pedersenHash } = require("./utils/pedersen.js");
const { findBet } = require("./utils/mimcMerkleTree.js");
const circomlibjs = require("circomlibjs");

////////////////////////////// MAIN ///////////////////////////////////////////
// forge-ffi-scripts/withdraw.js 0x3beeeb6bffb83c559c3c63c9d0049ec50286776b2517c6d6ec2e0f00660d7309 0x1e0 0x1 0x0 0x0 0x0
// forge-ffi-scripts/withdraw.js 0x03f6600c7331bd61106b32556f2676d57e81cf2b0bf6df800e6fcb4c53f56b009 0x01e0 0x01 0x0 0x0 0x0
// forge-ffi-scripts/withdraw.js 0x09340709afb154bbd3f9ccc089c0d5f2809f63fee47f88f2effe2dfeda432e16 0x0ff 0x01 0x0 0x0 0x0
// forge-ffi-scripts/withdraw.js 0x0872cabfcaa22225e755412927cc3595379767452f8813f4fa0af1d8b9ce9540a 0x0ff 0x01 0x0 0x0 0x0

async function main() {
  dotenv.config();
  const betMin = ethers.utils.parseUnits("1000000", 18);
  const inputs = process.argv.slice(2, process.argv.length);
  if(inputs.length == 0) {
    console.log("Usage: node reward.js <ticket or filename>");
    process.exit(1);
  }
  let tickets = [];
  if(inputs[0].startsWith("0x")) {
    tickets.push(inputs[0]);
  } else {
    const file = fs.readFileSync(inputs[0], "utf8");
    tickets = file.split("\n").filter(line => line.trim() !== "").map(line => line.trim());
  }
  for(const ticket of tickets) {
    const secret_power = hexToBigint(ticket.replace(/,.*/, ''));
    const startindex = parseInt(ticket.replace(/.*,/, ''));

    const mimcsponge = await circomlibjs.buildMimcSponge();
    const secret = secret_power>>8n;
    const power = secret_power & 0x1fn;
    const hash = await pedersenHash(leBigintToBuffer(secret, 31));
    const hash_power1 = hash + power + 1n;
    const [betIndex,betRand,nextIndex] = findBet(hash_power1,startindex);
    if(betIndex>0 && betRand==0n){
      console.log(ticket+" bet not processed yet");
      continue;
    }
    if(betIndex==0){
      console.log(ticket+" bet not found");
      continue;
    }
    const bigindex = BigInt(betIndex);
    const dice = await leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([secret,betRand,bigindex])));

  // 1.5. calculate reward
    const power1=10n;
    const power2=16n;
    const power3=22n;
    const mask = (power<=power1)?(((2n**(power1+power2+power3+1n)-1n)<<(power              ))                         )&(2n**(power1+power2+power3+1n)-1n) :
                ((power<=power2)?(((2n**(       power2+power3+1n)-1n)<<(power+power1       ))|(2n**(power1       )-1n))&(2n**(power1+power2+power3+1n)-1n) :
  			                         (((2n**(              power3+1n)-1n)<<(power+power1+power2))|(2n**(power1+power2)-1n))&(2n**(power1+power2+power3+1n)-1n));
    const maskdice= mask & dice;
    const rew1 = (maskdice &                                       0b1111111111n)?0n:1n ;
    const rew2 = (maskdice &                       0b11111111111111110000000000n)?0n:1n ;
    const rew3 = (maskdice & 0b111111111111111111111100000000000000000000000000n)?0n:1n ;
    const reward = betMin.mul(rew1*2n**power1+rew2*2n**power2+rew3*2n**power3);
    console.log(ticket+" "+ethers.utils.formatEther(reward));
  }
}

main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
