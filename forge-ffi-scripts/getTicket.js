#!/usr/bin/node

const { ethers } = require("ethers");
const { pedersenHash } = require("./utils/pedersen.js");
const { rbigint, bigintToHex, leBigintToBuffer, hexToBigint } = require("./utils/bigint.js");
const { getMask } = require("./utils/mask.js");
const { mimcRC } = require("./utils/mimcsponge.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);

  let amount = hexToBigint(inputs[0]);
  let ticket = hexToBigint(inputs[1]);
  let hash = 0n;
  let secret = 0n;
  let mask = 0n;

  if(ticket == 0n) {
    let i = 0n;
    for(; i < 256n; i++) {
      secret = rbigint(31);
      hash = await pedersenHash(leBigintToBuffer(secret, 31));
      if((hash & 0x1fn)==0n) {
        ticket = i;
        break;
      }
    }
    if(ticket >= 256n) {
      throw new Error("Failed to find ticket");
    }
    mask = getMask(amount);
    ticket = secret<<8n | i; // TODO: fix this
  }
  else {
    secret = ticket>>8n;
    const hash = await pedersenHash(leBigintToBuffer(secret, 31));
    amount=2n + 2n**(ticket & 0xFFn);
    mask = getMask(amount);
  }

  const mimc = await mimcRC(hash, mask);

  // 3. Return abi encoded hash, secret, mask, mimcR, mimcC, ticket
  const res = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint", "uint", "uint", "uint", "uint", "uint"],
    [bigintToHex(hash), bigintToHex(secret), bigintToHex(mask), bigintToHex(mimc.R), bigintToHex(mimc.C), bigintToHex(ticket)]
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
