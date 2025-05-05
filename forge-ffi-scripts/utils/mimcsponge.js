const circomlibjs = require("circomlibjs");

const { leBufferToBigint } = require("./bigint.js");

const mimcsponge2 = async (in1,in2) => {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const mimcspongeOut = leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([in1, in2])));
  return mimcspongeOut;
};

const mimcsponge3 = async (in1,in2,in3) => {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const mimcspongeOut = leBufferToBigint(mimcsponge.F.fromMontgomery(mimcsponge.multiHash([in1, in2, in3])));
  return mimcspongeOut;
};

const mimcspongehash = async (inL,inR,k) => {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const out = mimcsponge.hash(inL,inR,k);
  return {
    xL: leBufferToBigint(mimcsponge.F.fromMontgomery(out.xL)),
    xR: leBufferToBigint(mimcsponge.F.fromMontgomery(out.xR)),
  };
};

module.exports = {
  mimcsponge2,
  mimcsponge3,
  mimcspongehash,
};
