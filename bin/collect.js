#!/usr/bin/node
const dotenv = require("dotenv");
const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const readline = require('readline');
const { hexToBigint, bigintToHex, leBigintToBuffer, reverseBits, leBufferToBigint } = require("./utils/bigint.js");
const { pedersenHash } = require("./utils/pedersen.js");
const { getPath, findBet } = require("./utils/mimcMerkleTree.js");
const circomlibjs = require("circomlibjs");
const fs = require("fs");
const sprintfjs = require("sprintf-js");

// Create readline interface
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// Promise wrapper for readline question
function question(query) {
  return new Promise((resolve) => {
    rl.question(query, resolve);
  });
}
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
    console.log("Usage: node collect.js <ticket> <recipient> <relayer> <fee> <refund> <invest>");
    process.exit(1);
  }
  const secret_power = hexToBigint(inputs[0].replace(/,.*/, ''));
  const startindex = parseInt(inputs[0].replace(/.*,/, ''));

  const mimcsponge = await circomlibjs.buildMimcSponge();
  const secret = secret_power>>8n;
  const power = secret_power & 0x1fn;
  const hash = await pedersenHash(leBigintToBuffer(secret, 31));
  const hash_power1 = hash + power + 1n;
  const [betIndex,betRand,nextIndex] = findBet(hash_power1,startindex);
  if(betIndex>0 && betRand==0n){
    console.log("bet not processed yet for "+bigintToHex(hash_power1)+" starting at "+startindex.toString());
    process.exit(1);
  }
  if(betIndex==0){
    console.log("bet not found for "+bigintToHex(hash_power1)+" starting at "+startindex.toString());
    process.exit(1);
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
  const rewardbits = 4n*rew3+2n*rew2+rew1;
  const reward = betMin.mul(rew1*2n**power1+rew2*2n**power2+rew3*2n**power3);
  console.log("Reward: %s", ethers.utils.formatEther(reward));

  const ask = "Do You want to calculate the receipt for collecting the reward? (y/n): ";
  const answer = await question(ask);
  if(answer.toLowerCase() !== 'y') {
    process.exit(0);
  }

  const terces = reverseBits(dice,31*8);
  const nullifierHash = await pedersenHash(leBigintToBuffer(terces, 31));
  const pathElements = await getPath(betIndex,nextIndex);
  // 4. Format witness input to exactly match circuit expectations
  const input = {
    // Public inputs
    root: pathElements[32],
    nullifierHash: nullifierHash,
    rewardbits: rewardbits,
    recipient: hexToBigint(inputs[1]),
    relayer: hexToBigint(inputs[2]),
    fee: hexToBigint(inputs[3]),
    refund: hexToBigint(inputs[4]),
    // Private inputs
    secret: secret,
    power: power,
    rand: betRand,
    pathIndex: BigInt(betIndex),
    pathElements: pathElements.slice(0,32),
  };

  // 5. Create groth16 proof for witness
  console.log("Creating proof...");
  const { proof } = await snarkjs.groth16.fullProve(
    input,
    path.join(__dirname, "../groth16/withdraw.wasm"),
    path.join(__dirname, "../groth16/withdraw_final.zkey")
  );

  const pA = proof.pi_a.slice(0, 2);
  const pBin = proof.pi_b.slice(0, 2);
  const pB = [[pBin[0][1], pBin[0][0]], [pBin[1][1], pBin[1][0]]];
  const pC = proof.pi_c.slice(0, 2);

  // 6. Return abi encoded witness
  const encoded = ethers.utils.defaultAbiCoder.encode(
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "uint[7]"],
    [ pA,pB,pC,[bigintToHex(pathElements[32]),bigintToHex(nullifierHash),inputs[1],inputs[2],inputs[3],inputs[4],bigintToHex(rewardbits)]]
  );
  /*const decoded = ethers.utils.defaultAbiCoder.decode(
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "uint[7]"],
    encoded
  );*/
  console.log("writing receipt to receipts.txt...");
  const receiptFile = fs.openSync("receipts.txt", "a");
  fs.writeSync(receiptFile, `${inputs[0]},${encoded}\n`);
  fs.closeSync(receiptFile);

  const ask2 = sprintfjs.sprintf("Do You want to collect the reward at address %s now and invest %s FOOM? (y/n): ", inputs[1], ethers.utils.formatEther(inputs[5]));
  const answer2 = await question(ask2);
  if(answer2.toLowerCase() !== 'y') {
    process.exit(0);
  }

  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const lottery = new ethers.Contract(process.env.BASE_LOTTERY_ADDRESS, process.env.BASE_LOTTERY_ABI, wallet);
  const tx = await lottery.collect(pA,pB,pC,pathElements[32],nullifierHash,inputs[1],inputs[2],hexToBigint(inputs[3]),hexToBigint(inputs[4]),rewardbits,hexToBigint(inputs[5]));
  const receipt = await tx.wait();
  console.log("tx hash: %s", receipt.transactionHash);
}

main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
