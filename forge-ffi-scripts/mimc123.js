#!/usr/bin/node

const circomlibjs = require("circomlibjs");
const { bigintToHex, leBufferToBigint, } = require("./utils/bigint.js");

async function main() {
  const L = 1n;
  const R = 0n;
  const k = 0n;
  const mimcsponge = await circomlibjs.buildMimcSponge();
  console.log("L",L);
  console.log("R",R);
  console.log("k",k);
  const m1 = await mimcsponge.hash(L,R,k);
  console.log(bigintToHex(leBufferToBigint(m1.xL)));
  console.log(bigintToHex(leBufferToBigint(m1.xR)));
  //const ar = mimcsponge.getConstants();
  //console.log(":",ar[219]);

  const res2 = mimcsponge.multiHash([1,2]);
  console.log(mimcsponge.F.toString(res2,16));
  console.log(mimcsponge.F.toString(mimcsponge.F.e("0x2bcea035a1251603f1ceaf73cd4ae89427c47075bb8e3a944039ff1e3d6d2a6f"),16));
  //assert(mimcSponge.F.eq(mimcSponge.F.e("0x2bcea035a1251603f1ceaf73cd4ae89427c47075bb8e3a944039ff1e3d6d2a6f"), res2));
}

main()
  .then((wtns) => {
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
