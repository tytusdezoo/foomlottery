const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBigintToBuffer, reverseBits, } = require("./utils/bigint.js");
const { pedersenHash } = require("./utils/pedersen.js");
const { mimcsponge2,mimcsponge3, } = require("./utils/mimcsponge.js");
const { mimicMerkleTree } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);

  // 1. Get nullifier and secret
  const secret = hexToBigint(inputs[0]);
  console.log("start  %x", secret);
  const terces = reverseBits(secret,31*8);
  const mask = hexToBigint(inputs[1]);
  const rand = hexToBigint(inputs[2]);

  // 1.5. calculate reward
  const dice = await mimcsponge2(secret,rand);
  const maskdice= mask & dice;
  const rew1 = (maskdice &                                       0b1111111111n)?0:1
  const rew2 = (maskdice &                       0b11111111111111110000000000n)?0:1
  const rew3 = (dice     & 0b111111111111111111111100000000000000000000000000n)?0:1

  // 2. Get nullifier hash and commitment
  const nullifierHash = await pedersenHash(leBigintToBuffer((terces+rand)%21888242871839275222246405745257275088548364400416034343698204186575808495617n, 32));
  const SecretHashIn = await pedersenHash(leBigintToBuffer(secret, 32));
  console.log("mimcin  %x", SecretHashIn,mask,rand);
  const commitment = await mimcsponge3(SecretHashIn,mask,rand);
  console.log("mimcout %x", commitment);

  // 3. Create merkle tree, insert leaves and get merkle proof for commitment
  const leaves = inputs.slice(7, inputs.length).map((l) => hexToBigint(l));
  // fix leaves
  //  leaves[0] = commitment;
  const tree = await mimicMerkleTree(leaves);
  const merkleProof = tree.proof(commitment);

  // 4. Format witness input to exactly match circuit expectations
  const input = {
    // Public inputs
    root: merkleProof.pathRoot,
    nullifierHash: nullifierHash,
    reward1: rew1,
    reward2: rew2,
    reward3: rew3,
    recipient: hexToBigint(inputs[3]),
    relayer: hexToBigint(inputs[4]),
    fee: BigInt(inputs[5]),
    refund: BigInt(inputs[6]),

    // Private inputs
    secret: secret,
    mask: mask,
    rand: rand,
    pathElements: merkleProof.pathElements.map((x) => x.toString()),
    pathIndices: merkleProof.pathIndices,
  };

  // 5. Create groth16 proof for witness
  const { proof } = await snarkjs.groth16.fullProve(
    input,
    path.join(__dirname, "../circuit_artifacts/withdraw_js/withdraw.wasm"),
    path.join(__dirname, "../circuit_artifacts/withdraw_final.zkey")
  );

  const pA = proof.pi_a.slice(0, 2);
  const pB = proof.pi_b.slice(0, 2);
  const pC = proof.pi_c.slice(0, 2);

  // 6. Return abi encoded witness
  const witness = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "bytes32", "bytes32", "uint", "uint", "uint"],
    [
      pA,
      // Swap x coordinates: this is for proof verification with the Solidity precompile for EC Pairings, and not required
      // for verification with e.g. snarkJS.
      [
        [pB[0][1], pB[0][0]],
        [pB[1][1], pB[1][0]],
      ],
      pC,
      bigintToHex(merkleProof.pathRoot),
      bigintToHex(nullifierHash),
      bigintToHex(rew1),
      bigintToHex(rew2),
      bigintToHex(rew3),
    ]
  );

  return witness;
}

main()
  .then((wtns) => {
    process.stdout.write(wtns);
    process.exit(0);
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
