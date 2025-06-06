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
  const WETH_ADDRESS = "0x4200000000000000000000000000000000000006";
  const FOOM_ADDRESS = "0x02300aC24838570012027E0A90D3FEcCEF3c51d2";
  const TOKEN_ABI = ["function balanceOf(address) view returns (uint256)"];
  const FOOM_DEX_ADDRESS = "0xc5adb6F67c54D187a9FD8bA4994855e35963B69D";
  const FOOM_DEX_ABI = [
    "function slot0() external view returns (uint160 sqrtPriceX96, int24 tick, uint16 observationIndex, uint16 observationCardinality, uint16 observationCardinalityNext, uint8 feeProtocol, bool unlocked)",
  ];
  const betMin = ethers.utils.parseUnits("1000000", 18);
  const inputs = process.argv.slice(2, process.argv.length);
  if(inputs.length == 0) {
    console.log("Usage: node playETH.js <power:0-22>");
    process.exit(1);
  }
  let power = parseInt(inputs[0]);
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const lottery = new ethers.Contract(process.env.BASE_LOTTERY_ADDRESS, process.env.BASE_LOTTERY_ABI, wallet);

  const foom = new ethers.Contract(FOOM_ADDRESS, TOKEN_ABI, wallet);
  const weth = new ethers.Contract(WETH_ADDRESS, TOKEN_ABI, wallet);
  const foomdex = new ethers.Contract(FOOM_DEX_ADDRESS, FOOM_DEX_ABI, wallet);
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
  //console.log("FOOM needed: %s hex", foom_needed.toHexString());
  //console.log("FOOM needed: %s dec", foom_needed.toString());
  const dexfoomBalance = await foom.balanceOf(FOOM_DEX_ADDRESS);
  console.log("DEX FOOM balance: %s", ethers.utils.formatUnits(dexfoomBalance, 18));
  const wethBalance = await weth.balanceOf(FOOM_DEX_ADDRESS);
  console.log("DEX WETH balance: %s", ethers.utils.formatEther(wethBalance));
  const slot0 = await foomdex.slot0();
  const price = ethers.BigNumber.from(slot0.sqrtPriceX96).mul(ethers.BigNumber.from(slot0.sqrtPriceX96)).mul(10n**18n).div(2n**192n);
  console.log("DEX FOOM price in ETH: %s", ethers.utils.formatEther(price));
  //const amountInETH = price.mul(foom_needed).div(10n**18n).mul(200n).div(100n);
  //console.log("DEX amountInETH: %s (200%%)", ethers.utils.formatEther(amountInETH));
  const amountInETH = price.mul(foom_needed).div(10n**18n).mul(105n).div(100n);
  console.log("DEX amountInETH: %s (105%%)", ethers.utils.formatEther(amountInETH));
  
  if(balance.lt(amountInETH)) {
    console.log("Not enough ETH for this ticket power. You need %s ETH. You have %s ETH.The transaction from this account will fail.",
      (ethers.utils.formatEther(amountInETH)),
      (ethers.utils.formatEther(balance)));
    //rl.close();
    //process.exit(0);
  }
  let hash = 0n;
  let secret = 0n;
  let i = 0n;
  let secret_power = 0n;
  console.log("calculating secret for %s FOOM ticket...\n", ethers.utils.formatUnits(foom_needed, 18));
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
  const ask = sprintfjs.sprintf("Are you sure you want to play this ticket and send %s ETH? (y/n): ", ethers.utils.formatEther(amountInETH));
  const answer = await question(ask);
  if(answer.toLowerCase() !== 'y') {
    console.log("Aborted.");
    rl.close();
    process.exit(0);
  }
  // append to tickets.txt
  console.log("writing ticket to tickets.txt...");
  const ticketsFile = fs.openSync("tickets.txt", "a");
  fs.writeSync(ticketsFile, `${bigintToHex(secret_power)},${nextIndex.toString()}\n`);
  fs.closeSync(ticketsFile);
  
  const askprayer = sprintfjs.sprintf("Do you want to include a prayer? (keep empty for no prayer): ");
  const prayer = await question(askprayer);

  console.log("sending ticket...");
  let tx = null;
  if(prayer.length > 0) {
    tx = await lottery.playETHAndPray(hash, power, prayer, { value: amountInETH });
  } else {
    tx = await lottery.playETH(hash, power, { value: amountInETH });
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
