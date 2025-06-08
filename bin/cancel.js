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
  const inputs = process.argv.slice(2, process.argv.length);
  if(inputs.length == 0) {
    console.log("Usage: node cancel.js <ticket>");
    process.exit(1);
  }
  const secret_power = hexToBigint(inputs[0].replace(/,.*/, ''));
  const startindex = parseInt(inputs[0].replace(/.*,/, ''));

  const secret = secret_power>>8n;
  const power = secret_power & 0x1fn;
  const hash = await pedersenHash(leBigintToBuffer(secret, 31));
  const hash_power1 = hash + power + 1n;
  const [betIndex,betRand,nextIndex] = findBet(hash_power1,startindex);
  if(betIndex>0 && betRand>0n){
    throw("bet already processed for "+bigintToHex(hash_power1)+" starting at "+startIndex.toString(16));
  }
  if(betIndex==0){
    throw("bet not found for "+bigintToHex(hash_power1)+" starting at "+startIndex.toString(16));
  }
  
  const input = {
    inHash: hash,
    secret: secret
  };
  console.log("Creating proof...");
  const { proof } = await snarkjs.groth16.fullProve(
    input,
    path.join(__dirname, "../groth16/cancelbet.wasm"),
    path.join(__dirname, "../groth16/cancelbet_final.zkey")
  );

  const pA = proof.pi_a.slice(0, 2);
  const pBin = proof.pi_b.slice(0, 2);
  const pB = [[pBin[0][1], pBin[0][0]], [pBin[1][1], pBin[1][0]]];
  const pC = proof.pi_c.slice(0, 2);

  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const lottery = new ethers.Contract(process.env.BASE_LOTTERY_ADDRESS, process.env.BASE_LOTTERY_ABI, wallet);
  const gasPrice = await provider.getGasPrice();
  console.log("GAS price: %s", ethers.utils.formatUnits(gasPrice, 9));

  const ask = sprintfjs.sprintf("Do You want to cancel the ticket now? (y/n): ");
  const answer = await question(ask);
  if(answer.toLowerCase() !== 'y') {
    process.exit(0);
  }
  
  const tx = await lottery.cancelbet(pA,pB,pC,betIndex,wallet.address, { gasPrice: gasPrice });
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
