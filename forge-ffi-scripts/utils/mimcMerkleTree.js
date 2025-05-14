const circomlibjs = require("circomlibjs");
const { MerkleTree } = require("fixed-merkle-tree");

const { leBufferToBigint, hexToBigint } = require("./bigint.js");

// Constants from MerkleTreeWithHistory.sol
const MERKLE_TREE_HEIGHT = 32;

// Creates a fixed height merkle-tree with MiMC hash function (just like MerkleTreeWithHistory.sol)
async function mimicMerkleTree(zero,leaves = []) {
  //const pedersen = await circomlibjs.buildPedersenHash(); //TODO, not needed, fromMontgomery is in mimc
  const mimcsponge = await circomlibjs.buildMimcSponge();
  const leaf = (zero==0n)?16660660614175348086322821347366010925591495133565739687589833680199500683712n:zero;

  const mimcspongeMultiHash = (left, right) =>
    leBufferToBigint(
      //pedersen.babyJub.F.fromMontgomery(mimcsponge.multiHash([left, right]))
      mimcsponge.F.fromMontgomery(mimcsponge.multiHash([left, right]))
    );

  return new MerkleTree(MERKLE_TREE_HEIGHT, leaves, {
    hashFunction: mimcspongeMultiHash,
    zeroElement: leaf,
  });
}

module.exports = {
  mimicMerkleTree,
};
