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
  const WETH_ADDRESS = "0x4200000000000000000000000000000000000006";
  const FOOM_ADDRESS = "0x02300aC24838570012027E0A90D3FEcCEF3c51d2";
  const TOKEN_ABI = ["function balanceOf(address) view returns (uint256)"];
  const FOOM_DEX_ADDRESS = "0xc5adb6F67c54D187a9FD8bA4994855e35963B69D";
  const FOOM_DEX_ABI = [
    "function slot0() external view returns (uint160 sqrtPriceX96, int24 tick, uint16 observationIndex, uint16 observationCardinality, uint16 observationCardinalityNext, uint8 feeProtocol, bool unlocked)",
  ];
  const betMin = ethers.utils.parseUnits("1000000", 18);
  const inputs = process.argv.slice(2, process.argv.length);
  if(inputs.length < 2) {
    console.log("Usage: playETH.js <power:0-22> <0 or secret> <prayer:optional>");
    process.exit(1);
  }
  let power = parseInt(inputs[0]);
  let secret = hexToBigint(inputs[1].replace(/,.*/, ""))>>8n;
  if(secret == 0n) {
    secret = rbigint(31)-10000n;
  }
  let prayer = "";
  if(inputs.length > 2) {
    prayer = inputs.slice(2).join(" ");
    if(prayer === "read") {
      const { readPrayer } = require("./utils/prayers.js");
      prayer = await readPrayer();
      console.log("prayer: %s", prayer);
    }
  }
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const lottery = new ethers.Contract(process.env.BASE_LOTTERY_ADDRESS, process.env.BASE_LOTTERY_ABI, wallet);

  const gasPrice = await provider.getGasPrice();
  console.log("GAS price: %s", ethers.utils.formatUnits(gasPrice, 9));
  if(gasPrice.gte(ethers.utils.parseUnits(process.env.GAS_PRICE_LIMIT || "0.01", 9))) {
    console.log("GAS price is too high. Must be less than "+process.env.GAS_PRICE_LIMIT+" gwei.");
    process.exit(1);
  }
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
  let i = 0n;
  let secret_power = 0n;
  console.log("calculating secret for %s FOOM ticket...", ethers.utils.formatUnits(foom_needed, 18));
  for(; i < 10000n; i++) {
    hash = await pedersenHash(leBigintToBuffer(secret, 31));
    if((hash & 0x1fn)==0n) {
      break;
    }
    secret = secret + 1n;
  }
  if(i >= 10000n) { throw new Error("Failed to create ticket"); }
  secret_power = secret<<8n | BigInt(power);
  const [nextIndex,blockNumber,lastRoot,lastLeaf] = readLast();
  console.log("secret: %s,%s (index not final)",bigintToHex(secret_power),nextIndex.toString());
  console.log("hash: %s (use on basescan.org)",hash.toString());
  console.log("hash: %s",bigintToHex(hash));

  if(inputs.length < 3) {
    // checking luck
    const askluck = sprintfjs.sprintf("Do you want to test the luck of the secret on last bets? (0-1024): ");
    const answerluck = parseInt(await question(askluck));
    if(answerluck > 0 && answerluck <= 1024) {
      const wins = await secretLuck(secret,nextIndex,answerluck);
      const bets = wins[23];
      console.log("total bets: %d (values in M FOOM)", bets);
      console.log(sprintfjs.sprintf("%5s %11s %11s %11s %11s","power","cost","reward","profit","netprofit"));
      for(let i=0;i<22;i++) {
        if(i==10||i==16) {
          console.log(sprintfjs.sprintf("%5s %11s %11s %11s %11s","power","cost","reward","profit","netprofit"));
        } else {
          console.log(sprintfjs.sprintf("%5d %11d %11d %11d %11d", i, bets*(2+2**i), wins[i], wins[i]-bets*(2+2**i), wins[i]*0.96-bets*(2+2**i)));
        }
      }
    }
    // ask for confirmation using readline
    const ask = sprintfjs.sprintf("Are you sure you want to play this ticket and send %s ETH? (y/n): ", ethers.utils.formatEther(amountInETH));
    const answer = await question(ask);
    if(answer.toLowerCase() !== 'y') {
      console.log("Aborted.");
      rl.close();
      process.exit(0);
    }
  }
  
  if(prayer.length == 0) {
    const askprayer = sprintfjs.sprintf("Do you want to include a prayer? (keep empty for no prayer): ");
    prayer = await question(askprayer);
  }
  rl.close();
  // play the ticket
  console.log("sending ticket...");
  let tx = null;
  if(prayer.length > 0) {
    tx = await lottery.playETHAndPray(hash, power, prayer, { value: amountInETH, gasPrice: gasPrice.mul(110).div(100) });
  } else {
    tx = await lottery.playETH(hash, power, { value: amountInETH, gasPrice: gasPrice.mul(110).div(100) });
  }
  const receipt = await tx.wait();
  console.log("tx hash: %s", receipt.transactionHash);

    // find logBetIn in transaction log 
  const logBetIn = receipt.logs.find(log => log.address === lottery.address &&
     log.topics[0] === "0x67024112d4ff1b7b177f96a8d0a53bb255e6f8eb3e7b1c9e9400d7f0de991a56");
  if(logBetIn) {
    const newIndex = hexToBigint(logBetIn.topics[1]);
    const newHash = hexToBigint(logBetIn.topics[2]);
    if(newHash != hash + BigInt(power) + 1n) {
      console.log("ERROR: newHash is not correct! Something went wrong. Ticket not saved in tickets.txt!");
      return;
    }
    // append to tickets.txt
    console.log("writing ticket to tickets.txt...");
    console.log("\nsecret: %s,%s\n",bigintToHex(secret_power),newIndex.toString());
    const ticketsFile = fs.openSync("tickets.txt", "a");
    fs.writeSync(ticketsFile, `${bigintToHex(secret_power)},${newIndex.toString()}\n`);
    fs.closeSync(ticketsFile);
  } else {
    console.log("ERROR: logBetIn not found! Transaction may have failed. Ticket not saved in tickets.txt!");
    return;
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
