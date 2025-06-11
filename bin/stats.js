#!/usr/bin/node
const dotenv = require("dotenv");
const { ethers } = require("ethers");
const readline = require('readline');
const { pedersenHash } = require("./utils/pedersen.js");
const { rbigint, bigintToHex, leBigintToBuffer } = require("./utils/bigint.js");
const { readLast } = require("./utils/mimcMerkleTree.js");
const fs = require("fs");
const sprintfjs = require("sprintf-js");

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

  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const lottery = new ethers.Contract(process.env.BASE_LOTTERY_ADDRESS, process.env.BASE_LOTTERY_ABI, wallet);

  const foom = new ethers.Contract(FOOM_ADDRESS, FOOM_ABI, wallet);
  const foomBalance = await foom.balanceOf(lottery.address);
  console.log("FOOM Lottery balance: %s M FOOM", ethers.utils.formatEther(foomBalance)/1000000);
  // read last
  const [nextIndex,blockNumber,lastRoot,lastLeaf] = readLast();
  console.log("FOOM Lottery total number of tickets: %d", nextIndex);

  for (let i = 1;; i++) {
    const period = await lottery.periods(i);
    const bets = ethers.utils.formatUnits(period.bets.toString(), 18).replace(/\..*$/, "");
    const shares = ethers.utils.formatUnits(period.shares.toString(), 18).replace(/\..*$/, "");
    if(period.shares.eq(0)) {
      break;
    }
    if(period.bets.lt(period.shares)) {
      const apr = (1.0+0.04*bets/shares)**((60*60*24*365)/(16384*2))-1;
      console.log("Period %s: %s M volume, %s M shares, %s APR", i, bets/1000000, shares/1000000, sprintfjs.sprintf("%.2f", apr*100));
    }
    else {
      console.log("Period %s: %s M volume, %s M shares", i, bets/1000000, shares/1000000);
    }
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
