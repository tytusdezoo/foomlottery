#!/usr/bin/node
const dotenv = require("dotenv");
const { ethers } = require("ethers");
const fs = require("fs");
const { hexToBigint, leBigintToBuffer, leBufferToBigint } = require("./utils/bigint.js");
const { pedersenHash } = require("./utils/pedersen.js");
const { findBet } = require("./utils/mimcMerkleTree.js");
const circomlibjs = require("circomlibjs");

////////////////////////////// MAIN ///////////////////////////////////////////

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
    // convert to binary string with fixed length 10, 16, 22
    const bits1 = (maskdice &                                       0b1111111111n).toString(2).padStart(10, '0');
    const bits2 = ((maskdice &                       0b11111111111111110000000000n)>>10n).toString(2).padStart(16, '0');
    const bits3 = ((maskdice & 0b111111111111111111111100000000000000000000000000n)>>26n).toString(2).padStart(22, '0');
    console.log(ticket+" "+ethers.utils.formatEther(reward)+" "+bits1+" "+bits2+" "+bits3);
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
