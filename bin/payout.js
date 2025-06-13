#!/usr/bin/node
const dotenv = require("dotenv");
const { ethers } = require("ethers");
const readline = require('readline');
const { pedersenHash } = require("./utils/pedersen.js");
const { rbigint, bigintToHex, leBigintToBuffer, hexToBigint } = require("./utils/bigint.js");
const { readLast } = require("./utils/mimcMerkleTree.js");
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

async function main() {
  dotenv.config();
  const FOOM_ADDRESS = "0x02300aC24838570012027E0A90D3FEcCEF3c51d2";
  const FOOM_ABI = [
    "function balanceOf(address) view returns (uint256)",
    "function approve(address,uint256) external returns (bool)",
    "function allowance(address,address) view returns (uint256)",
    "function walletBalanceOf(address) view returns (uint256)",
  ];
  const betMin = ethers.utils.parseUnits("1000000", 18);
  const inputs = process.argv.slice(2, process.argv.length);
  if(inputs.length == 0) {
    console.log("Usage: payout.js <FOOM_amount>");
    process.exit(1);
  }

  const foom_amount = ethers.utils.parseUnits(inputs[0], 18);
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const lottery = new ethers.Contract(process.env.BASE_LOTTERY_ADDRESS, process.env.BASE_LOTTERY_ABI, wallet);

  const gasPrice = await provider.getGasPrice();
  console.log("GAS price: %s", ethers.utils.formatUnits(gasPrice, 9));
  const foom = new ethers.Contract(FOOM_ADDRESS, FOOM_ABI, wallet);
  console.log("Wallet address:", wallet.address);
  const balance = await provider.getBalance(wallet.address);
  console.log("ETH  balance:", ethers.utils.formatEther(balance));
  const foomBalance = await foom.balanceOf(wallet.address);
  console.log("FOOM balance: %s", ethers.utils.formatEther(foomBalance));
  const walletBalance = await lottery.walletBalanceOf(wallet.address);
  console.log("Lottery balance: %s", ethers.utils.formatUnits(walletBalance, 18));
  const dividendPeriod = await lottery.dividendPeriod();
  console.log("Dividend period: %s", dividendPeriod);
  const walletWithdrawPeriod = await lottery.walletWithdrawPeriodOf(wallet.address);
  console.log("Wallet withdraw period: %s", walletWithdrawPeriod);

  if(walletBalance.lt(foom_amount)) {
    console.log("Not enough FOOM for this payout");
    rl.close();
    return;
  }
  if(walletWithdrawPeriod.gt(dividendPeriod)) {
    console.log("Must wait for next dividend period");
    rl.close();
    return;
  }

  const ask = sprintfjs.sprintf("Are you sure you want to pay out %s FOOM? (y/n): ", ethers.utils.formatUnits(foom_amount, 18));
  const answer = await question(ask);
  if(answer.toLowerCase() !== 'y') {
    console.log("Aborted.");
    rl.close();
    return;
  }

  const tx = await lottery.payOut(foom_amount, { gasPrice: gasPrice.mul(110).div(100) });
  const receipt = await tx.wait();
  console.log("tx hash: %s", receipt.transactionHash);
  rl.close();
}

main()
  .then(() => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
