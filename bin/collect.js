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
  const betMin = ethers.utils.parseUnits("1000000", 18);
  const inputs = process.argv.slice(2, process.argv.length);
  if(inputs.length == 0) {
    console.log("Usage: node collect.js <ticket> <recipient_address> <relayer_address> <fee_in_FOOM> <refund_in_ETH> <invest_in_FOOM>");
    process.exit(1);
  }
  const secret_power = hexToBigint(inputs[0].replace(/,.*/, ''));
  const startindex = parseInt(inputs[0].replace(/.*,/, ''));
  const recipient_address = hexToBigint(inputs[1]);
  const relayer_address = hexToBigint(inputs[2]);
  // convert decimal to bigNumber
  const fee_in_FOOM = ethers.utils.parseUnits(inputs[3], 18);
  const refund_in_ETH = ethers.utils.parseUnits(inputs[4], 18);
  const invest_in_FOOM = ethers.utils.parseUnits(inputs[5], 18);

  console.log("recipient_address:", ethers.utils.getAddress(recipient_address.toString(16)));
  console.log("relayer_address  :", ethers.utils.getAddress(relayer_address==0n?'0x0000000000000000000000000000000000000000':relayer_address.toString(16)));
  console.log("fee_in_FOOM:", ethers.utils.formatUnits(fee_in_FOOM, 18));
  console.log("refund_in_ETH:", ethers.utils.formatEther(refund_in_ETH));
  console.log("invest_in_FOOM:", ethers.utils.formatUnits(invest_in_FOOM, 18));
  //process.exit(0);

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
  console.log("Reward_in_FOOM: %s %s", ethers.utils.formatEther(reward), rewardbits==0n?'no need to claim!':'');

  const ask = sprintfjs.sprintf("Do You want to calculate the receipt for collecting the reward%s? (y/n): ",rewardbits==0n?' anyway':'');
  const answer = await question(ask);
  if(answer.toLowerCase() !== 'y') {
    process.exit(0);
  }

  const terces = reverseBits(dice,31*8);
  const nullifierHash = await pedersenHash(leBigintToBuffer(terces, 31));
  const provider = new ethers.providers.JsonRpcProvider(process.env.RPC_URL);
  const wallet = new ethers.Wallet(process.env.PRIVATE_KEY, provider);
  const lottery = new ethers.Contract(process.env.BASE_LOTTERY_ADDRESS, process.env.BASE_LOTTERY_ABI, wallet);
  const collected = await lottery.nullifier(nullifierHash);
  if(collected.gt(0)) {
    console.log("ticket already collected!");
    process.exit(1);
  }
  const pathElements = await getPath(betIndex,nextIndex);
  // 4. Format witness input to exactly match circuit expectations
  const input = {
    // Public inputs
    root: pathElements[32],
    nullifierHash: nullifierHash,
    rewardbits: rewardbits,
    recipient: recipient_address,
    relayer: relayer_address,
    fee: hexToBigint(fee_in_FOOM.toHexString()),
    refund: hexToBigint(refund_in_ETH.toHexString()),
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
    [ pA,pB,pC,
      [bigintToHex(pathElements[32]),
      bigintToHex(nullifierHash),
      bigintToHex(recipient_address),
      bigintToHex(relayer_address),
      bigintToHex(input.fee),
      bigintToHex(input.refund),
      bigintToHex(rewardbits)]
    ]
  );
  const d = ethers.utils.defaultAbiCoder.decode(["uint256[2]", "uint256[2][2]", "uint256[2]", "uint[7]"],encoded);

  const ask2 = sprintfjs.sprintf("Do You want to collect the reward at address %s now and invest %s FOOM in the lottery? (y/n): ",
    ethers.utils.getAddress(recipient_address.toString(16)), ethers.utils.formatUnits(invest_in_FOOM, 18));
  const answer2 = await question(ask2);
  if(answer2.toLowerCase() == 'y') {
    const relayer = d[3][3].eq(0)?'0x0000000000000000000000000000000000000000':d[3][3].toHexString();
    //const tx = await lottery.collect(pA,pB,pC,pathElements[32],nullifierHash,inputs[1],inputs[2],hexToBigint(inputs[3]),hexToBigint(inputs[4]),rewardbits,hexToBigint(inputs[5]));
    const tx = await lottery.collect(d[0],d[1],d[2],d[3][0],d[3][1],d[3][2].toHexString(),relayer,d[3][4],d[3][5],d[3][6],invest_in_FOOM);
    const receipt = await tx.wait();
    console.log("tx hash: %s", receipt.transactionHash);
  } else {
    console.log("Use this receipt for collecting later!\n");
    console.log(encoded);
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
