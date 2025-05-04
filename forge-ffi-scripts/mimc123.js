#!/usr/bin/node

const circomlibjs = require("circomlibjs");
const { bigintToHex, leBufferToBigint, } = require("./utils/bigint.js");

async function main() {
  const L = 1n;
  const R = 2n;
  const k = 0n;
  const mimcsponge = await circomlibjs.buildMimcSponge();
  console.log("L",L);
  console.log("R",R);
  console.log("k",k);
  const m1 = await mimcsponge.hash(L,R,k);
  console.log(bigintToHex(leBufferToBigint(m1.xL)));
  console.log(bigintToHex(leBufferToBigint(m1.xR)));
}

main()
  .then((wtns) => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
