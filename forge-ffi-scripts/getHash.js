#!/usr/bin/node

const { ethers } = require("ethers");
const { pedersenHash } = require("./utils/pedersen.js");
const { rbigint, bigintToHex, leBigintToBuffer, hexToBigint } = require("./utils/bigint.js");
//const { getMask } = require("./utils/mask.js");
//const { mimcRC } = require("./utils/mimcsponge.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);

  let power = hexToBigint(inputs[0]);
  let hash = 0n;
  let secret = 0n;
  let i = 0n;
  let secret_power = 0n;
  if(power>=0x1fn){
    secret_power = power;
    hash = await pedersenHash(leBigintToBuffer(secret_power>>8n, 31));
  }
  else{
    for(; i < 10000n; i++) {
      secret = rbigint(31);
      hash = await pedersenHash(leBigintToBuffer(secret, 31));
      if((hash & 0x1fn)==0n) {
        ticket = i;
        break;
      }
    }
    if(ticket >= 10000n) { throw new Error("Failed to find ticket"); }
    secret_power = secret<<8n | power;
  }

  // 3. Return abi encoded hash, secret+power
  const res = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint", "uint"],
    [bigintToHex(hash), bigintToHex(secret_power)]
  );
  return res;
}

main()
  .then((res) => {
    process.stdout.write(res);
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
