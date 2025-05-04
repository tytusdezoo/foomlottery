const circomlibjs = require("circomlibjs");

const { leBufferToBigint } = require("./bigint.js");

const mimcsponge2 = async (in1,in2) => {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const mimcspongeOut = leBufferToBigint(mimcsponge.multiHash([in1, in2]));
  return mimcspongeOut;
};

const mimcsponge3 = async (in1,in2,in3) => {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const mimcspongeOut = leBufferToBigint(mimcsponge.multiHash([in1, in2, in3]));
  return mimcspongeOut;
};

const mimcspongehash = async (inL,inR,k) => {
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const out = mimcsponge.hash(inL,inR,k);
  return {
    xL: out.xL,
    xR: out.xR,
  };
};

module.exports = {
  mimcsponge2,
  mimcsponge3,
  mimcspongehash,
};
