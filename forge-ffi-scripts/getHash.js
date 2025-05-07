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
  if(power<1||power>=2*5){ throw new Error("Wrong Input");}
  let hash = 0n;
  let secret = 0n;
  let i = 0n;
  for(; i < 256n; i++) {
    secret = rbigint(31);
    hash = await pedersenHash(leBigintToBuffer(secret, 31));
    if((hash & 0x1fn)==0n) {
      ticket = i;
      break;
    }
  }
  if(ticket >= 256n) { throw new Error("Failed to find ticket"); }
  secret = secret<<8n | i;

  // 3. Return abi encoded hash, secret+power
  const res = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint", "uint"],
    [bigintToHex(hash), bigintToHex(secret)]
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
