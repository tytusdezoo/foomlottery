const circomlibjs = require("circomlibjs");

const { leBufferToBigint } = require("./bigint.js");

const mimcsponge2 = async (in1,in2) => {
  const mimcsponge = await circomlibjs.buildMimcSponge();

  const mimcspongeOut = leBufferToBigint(
        pedersen.babyJub.F.fromMontgomery(mimcsponge.multiHash([in1, in2]))
	    );
  return mimcspongeOut;
};

const mimcsponge3 = async (in1,in2,in3) => {
  const mimcsponge = await circomlibjs.buildMimcSponge();

  const mimcspongeOut = leBufferToBigint(
        pedersen.babyJub.F.fromMontgomery(mimcsponge.multiHash([in1, in2, in3]))
	    );
  return mimcspongeOut;
};

module.exports = {
  mimcsponge2,
  mimcsponge3,
};
