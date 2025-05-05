const { ethers } = require("ethers");
const { pedersenHash } = require("./utils/pedersen.js");
const { rbigint, bigintToHex, leBigintToBuffer, hexToBigint } = require("./utils/bigint.js");
const { getMask } = require("./utils/mask.js");
const { mimcRC } = require("./utils/mimcsponge.js");
// Intended output: (bytes32 commitment, bytes32 nullifier, bytes32 secret)

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);

  // 1. Get nullifier and secret
  const amount = hexToBigint(inputs[0]);
  const secret = rbigint(31);

  // 2. Get commitment
  const commitment = await pedersenHash(leBigintToBuffer(secret, 31));

  // 3. Get mask
  //console.log(bigintToHex(amount));
  const mask = await getMask(amount);
  //console.log(bigintToHex(mask));
  // 4. Get mimc hash
  const mimc = await mimcRC(commitment, mask);

  // 3. Return abi encoded nullifier, secret, commitment
  const res = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint", "uint", "uint", "uint", "uint"],
    [bigintToHex(commitment), bigintToHex(secret), bigintToHex(mask), bigintToHex(mimc.R), bigintToHex(mimc.C)]
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
