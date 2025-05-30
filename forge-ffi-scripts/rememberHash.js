#!/usr/bin/node
//#!/usr/bin/node --env-file=.env

const dotenv = require("dotenv");
const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBigintToBuffer, reverseBits, leBufferToBigint } = require("./utils/bigint.js");
const { pedersenHash } = require("./utils/pedersen.js");
const { getPath, findBet } = require("./utils/mimcMerkleTree.js");
const circomlibjs = require("circomlibjs");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  // ask node to read dotenv file
  dotenv.config();
  // create a new ethers provider
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  // create a new ethers wallet
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  // print wallet address
  //console.log("Wallet address:", wallet.address);
  // print wallet balance
  //const balance = await provider.getBalance(wallet.address);
  //console.log("Wallet balance:", ethers.utils.formatEther(balance));
  // connect to the lottery contract
  const lottery = new ethers.Contract(process.env.BASE_LOTTERY_ADDRESS, process.env.BASE_LOTTERY_ABI, wallet);
  // call contract betsIndex()
  const commitIndex = await lottery.commitIndex();
  // console.log("Commit index:", commitIndex.toString());
  if(commitIndex > 0n) {
    // create raw transaction lottery.rememberHash()
    const tx = await lottery.rememberHash();
    console.log("Tx:", tx);
    // wait for transaction to be mined
    const receipt = await tx.wait();
    console.log("Transaction receipt:", receipt);
  }
 
}

main()
  .then((wtns) => {
    //process.stdout.write(wtns);
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
