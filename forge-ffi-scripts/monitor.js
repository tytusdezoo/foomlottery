#!/usr/bin/node
//#!/usr/bin/node --env-file=.env

const dotenv = require("dotenv");
const { ethers } = require("ethers");
const { readLast, readLastLog, writeLastLog, writeWaiting, readRevealLock, readWaitingBlocknumber } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function rememberHash(lottery) {
  const commitIndex = await lottery.commitIndex();
  if(commitIndex > 0n) {
    const tx = await lottery.rememberHash();
    console.log("Remember hash transaction:", tx);
    const receipt = await tx.wait();
    console.log("Remember hash transaction receipt:", receipt);
  }
}

async function commit(provider,lottery) {
  const minBets = 8;
  const minBlocks = 30*60; // 60 minutes on Base
  const blockNumber = await provider.getBlockNumber();
  const nextIndex = await lottery.nextIndex();
  const betsIndex = await lottery.betsIndex();
  const commitIndex = await lottery.commitIndex();
  const [lastIndex,lastBlockNumber,lastRoot,lastLeaf] = readLast();
  if(betsIndex > 0 && lastIndex == nextIndex && commitIndex == 0) {
    const waitingBlocknumber = readWaitingBlocknumber();
    if((waitingBlocknumber > 0 && waitingBlocknumber <= blockNumber - minBlocks) || (betsIndex >= minBets)) {
      // commit if betsIndex is not 0 and enough time has passed
      const revealSecretInput = process.env.PRIVATE_KEY+'_FOOM_'+nextIndex.toString(16);
      const revealSecret = ethers.utils.keccak256(revealSecretInput);
      const revealSecretHash = ethers.utils.keccak256(revealSecret);
      const tx = await lottery.commit(revealSecretHash);
      console.log("Commit transaction:", tx);
      const receipt = await tx.wait();
      console.log("Commit transaction receipt:", receipt);
    }
  }
}

async function reveal(lottery,index,commitIndex,commitHash,commitBlockHash) {
  const nextIndex = await lottery.nextIndex();
  if(index == nextIndex) { // TODO: check if this is needed
    const revealSecretInput = process.env.PRIVATE_KEY+'_FOOM_'+nextIndex.toString(16);
    const revealSecret = ethers.utils.keccak256(revealSecretInput);
    const revealSecretHash = ethers.utils.keccak256(revealSecret);
    if(revealSecretHash == commitHash) {
      if(readRevealLock()==index) {
        return;
      }
      writeRevealLock(index); 
      const output = await update(commitIndex,commitHash,commitBlockHash);
      const tx = await lottery.reveal(revealSecret,output.pA,output.pB,output.pC,output.newRoot);
      const receipt = await tx.wait();
      console.log("Reveal transaction receipt:", receipt);
      if(receipt.status == 1) {
        writeRevealLock(0);
      } else {
        console.log("Reveal transaction failed");
        // publish secret to the network
        const tx = await lottery.secret(revealSecret);
        const receipt = await tx.wait();
        console.log("Publish secret transaction receipt:", receipt);
      }
    } else {
      console.log("Reveal secret hash does not match commit hash");
    }
  }
}

async function readLogs(provider,lottery,generator,walletAddress) {
  const CHUNK_SIZE = 99;
  let [lastIndex,lastBlockNumber,lastRoot,lastLeaf] = readLast();
  let [logsBlockNumber,logsTransactionIndex] = readLastLog();
  const blockNumber = await provider.getBlockNumber();
  for(let currentBlock = logsBlockNumber; currentBlock < blockNumber; currentBlock += CHUNK_SIZE) {
    const endBlock = Math.min(currentBlock + CHUNK_SIZE, blockNumber);
    console.log(`Querying blocks ${currentBlock} to ${endBlock} max ${blockNumber}`);    
    const logs = await lottery.queryFilter({}, currentBlock, endBlock);
    for(let i=0;i<logs.length;i++) {
      const log = logs[i];
      if(log.removed || log.blockNumber < logsBlockNumber || (log.blockNumber == logsBlockNumber && log.transactionIndex <= logsTransactionIndex)) {
        continue;
      }
      console.log("Log:", log);
      if(log.event == "LogChangeGenerator") {
        console.log("Change generator:", log.args);
        generator = log.args.generator;
      }
      if(log.event == "LogBetIn") {
        console.log("Bet in:", log.args);
        writeWaiting(log.args.index,log.args.newHash,log.blockNumber);
      }
      if(log.event == "LogCancel") {
        console.log("Cancel:", log.args);
        writeWaiting(log.args.index,0x20n,log.blockNumber);
      }
      if(log.event == "LogUpdate") {
        console.log("LogUpdate:", log.args);
        const index = Number(log.args.newIndex);
        if(index > lastIndex) { // newIndex should be smaller than lastIndex + 256, otherwise the update will fail
          await putLeaves(index,log.args.newRand,log.args.newRoot,log.blockNumber);
          [lastIndex,lastBlockNumber,lastRoot,lastLeaf] = readLast();
        }
      }
      if(log.event == "LogCommit") {
        console.log("LogCommit:", log.args);
        const index = Number(log.args.index);
        if(index == lastIndex) {
          if(generator == walletAddress) {
            await reveal(lottery,index,Number(log.args.commitIndex),log.args.commitHash,log.blockHash);
          }
          // TODO, log data in case secret will be revealed later
        }
      }
      logsBlockNumber = log.blockNumber;
      logsTransactionIndex = log.transactionIndex;
    }
    writeLastLog(logsBlockNumber,logsTransactionIndex);
    //break; // TODO: remove this after tests
  }
  // write blockNumber to logs.csv
  return generator;
}

async function main() {
  dotenv.config();
  const inputs = process.argv.slice(2, process.argv.length);
  const task = inputs.length > 0 ? inputs[0] : "";
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const lottery = new ethers.Contract(process.env.BASE_LOTTERY_ADDRESS, process.env.BASE_LOTTERY_ABI, wallet);
  let generator = await lottery.generator();
  //console.log("Wallet address:", wallet.address);
  //const balance = await provider.getBalance(wallet.address);
  //console.log("Wallet balance:", ethers.utils.formatEther(balance));

  await rememberHash(lottery);
  generator = await readLogs(provider,lottery,generator,wallet.address);
  if(task == "commit" && generator == wallet.address) { // TODO, update generator if needed
    await commit(provider,lottery);
    generator = await readLogs(provider,lottery,generator,wallet.address);
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
