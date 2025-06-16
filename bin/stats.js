#!/usr/bin/node
const dotenv = require("dotenv");
const { ethers } = require("ethers");
const { readLast } = require("./utils/mimcMerkleTree.js");
const sprintfjs = require("sprintf-js");
const chain = require("../forge-ffi-scripts/utils/chain.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  dotenv.config();
  if(!process.env.FOOM_URL) {
    process.env.FOOM_URL = chain.foom_url();
  }

  const provider = new ethers.providers.JsonRpcProvider(chain.rpc_url());
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const lottery = new ethers.Contract(chain.lottery_address(), chain.lottery_abi(), wallet);

  const foom = new ethers.Contract(chain.foom_address(), chain.foom_abi(), wallet);
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
