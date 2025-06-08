#!/usr/bin/node
const dotenv = require("dotenv");
const { ethers } = require("ethers");
const readline = require('readline');
const { pedersenHash } = require("./utils/pedersen.js");
const { rbigint, bigintToHex, leBigintToBuffer } = require("./utils/bigint.js");
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
  ];
  const betMin = ethers.utils.parseUnits("1000000", 18);
  const inputs = process.argv.slice(2, process.argv.length);
  if(inputs.length == 0) {
    console.log("Usage: node play.js <power:0-22> <prayer:optional>");
    process.exit(1);
  }
  let prayer = "";
  if(inputs.length > 1) {
    prayer = inputs.slice(1).join(" ");
    if(prayer === "read") {
      const { readPrayer } = require("./utils/prayers.js");
      prayer = await readPrayer();
      console.log("prayer: %s", prayer);
    }
  }
  let power = parseInt(inputs[0]);
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const lottery = new ethers.Contract(process.env.BASE_LOTTERY_ADDRESS, process.env.BASE_LOTTERY_ABI, wallet);


  const gasPrice = await provider.getGasPrice();
  console.log("GAS price: %s", ethers.utils.formatUnits(gasPrice, 9));
  if(gasPrice.gte(ethers.utils.parseUnits(process.env.GAS_PRICE_LIMIT || "0.01", 9))) {
    console.log("GAS price is too high. Must be less than "+process.env.GAS_PRICE_LIMIT+" gwei.");
    process.exit(1);
  }
  const foom = new ethers.Contract(FOOM_ADDRESS, FOOM_ABI, wallet);
  console.log("Wallet address:", wallet.address);
  const balance = await provider.getBalance(wallet.address);
  console.log("ETH  balance:", ethers.utils.formatEther(balance));
  const foomBalance = await foom.balanceOf(wallet.address);
  console.log("FOOM balance: %s", ethers.utils.formatEther(foomBalance));

  // Calculate FOOM needed using ethers BigNumber
  const powerBN = ethers.BigNumber.from(power);
  const twoBN = ethers.BigNumber.from(2);
  const foom_needed = betMin.mul(twoBN.add(twoBN.pow(powerBN)));
  console.log("FOOM  needed: %s", ethers.utils.formatUnits(foom_needed, 18));

  if(foomBalance.lt(foom_needed)) {
    console.log("Not enough FOOM for this ticket power. You need %s FOOM. You have %s FOOM. The transaction from this account will fail.",
      (ethers.utils.formatUnits(foom_needed, 18)),
      (ethers.utils.formatEther(foomBalance)));
    //rl.close();
    //process.exit(0);
  }
  let hash = 0n;
  let secret = 0n;
  let i = 0n;
  let secret_power = 0n;
  console.log("calculating secret for %s FOOM ticket...\n", (ethers.utils.formatUnits(foom_needed, 18)));
  for(; i < 10000n; i++) {
    secret = rbigint(31);
    hash = await pedersenHash(leBigintToBuffer(secret, 31));
    if((hash & 0x1fn)==0n) {
      break;
    }
  }
  if(i >= 10000n) { throw new Error("Failed to create ticket"); }
  secret_power = secret<<8n | BigInt(power);
  const [nextIndex,blockNumber,lastRoot,lastLeaf] = readLast();
  console.log("secret: %s,%s\n",bigintToHex(secret_power),nextIndex.toString());
  console.log("hash: %s (use on basescan.org)",hash.toString());
  console.log("hash: %s",bigintToHex(hash));

  // ask for confirmation using readline
  if(inputs.length == 1) {
    const ask = sprintfjs.sprintf("Are you sure you want to play this ticket and send %s FOOM? (y/n): ", ethers.utils.formatEther(foom_needed));
    const answer = await question(ask);
    if(answer.toLowerCase() !== 'y') {
      console.log("Aborted.");
      rl.close();
      process.exit(0);
    }
  }
  // append to tickets.txt
  console.log("writing ticket to tickets.txt...");
  const ticketsFile = fs.openSync("tickets.txt", "a");
  fs.writeSync(ticketsFile, `${bigintToHex(secret_power)},${nextIndex.toString()}\n`);
  fs.closeSync(ticketsFile);

  if(prayer.length == 0) {
    const askprayer = sprintfjs.sprintf("Do you want to include a prayer? (keep empty for no prayer): ");
    prayer = await question(askprayer);
  }
  // check allowance of foom if needed
  const allowance = await foom.allowance(wallet.address, lottery.address);
  if(allowance.lt(foom_needed)) {
    console.log("approving foom...");
    const approveTx = await foom.approve(lottery.address, foom_needed, { gasPrice: gasPrice.mul(110).div(100) });
    const approveReceipt = await approveTx.wait();
    console.log("approve tx hash: %s", approveReceipt.transactionHash);
  }
  // play the ticket
  console.log("sending ticket...");
  let tx = null;
  if(prayer.length > 0) {
    //tx = await lottery.playAndPray(hash,power,prayer, { gasPrice: gasPrice.mul(110).div(100), gasLimit: 70000 });
    tx = await lottery.playAndPray(hash,power,prayer, { gasPrice: gasPrice.mul(110).div(100) });
  } else { // liimt 
    tx = await lottery.play(hash,power, { gasPrice: gasPrice.mul(110).div(100) });
  }
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
