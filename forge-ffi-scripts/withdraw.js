#!/usr/bin/node

const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBigintToBuffer, reverseBits, } = require("./utils/bigint.js");
const { pedersenHash } = require("./utils/pedersen.js");
const { mimcsponge3 } = require("./utils/mimcsponge.js");
const { mimicMerkleTree } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////
// forge-ffi-scripts/withdraw.js 0x00713bf224fe30b7dd98a71c9fbedd2256b6baa7f7352625b2d20a8d57ed573b 0x000000000000000000000000000000000000000000000000000000000000000a 0x000000000000000000000000000000009c9066d48f17e8c6b1a65301e91a2e36 0x0000000000000000000000000000000000000000000000000000000000000001 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 0x0000000000000000000000000000000000000000 0 0 0x16d18e1425b426e92d3d897958aabf099087b2401bfed53290f5a81fe73c69a5 0x10be442a30c17aeae384745acc09e61e2ec2d14f7d374d98f6bab9c5d7e38071

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);

  const secret = hexToBigint(inputs[0]);
  const power = hexToBigint(inputs[1]);
  const rand = hexToBigint(inputs[2]);
  const index = hexToBigint(inputs[3]);
  const dice = await mimcsponge3(secret,rand,index);
  const terces = reverseBits(dice,31*8);

  // 1.5. calculate reward
  const power1=10n;
  const power2=16n;
  const mask = (power<=power1)?((2n**(power1+power2+1n)-1n)<<power)&(2n**(power1+power2+1n)-1n):(((2n**power2-1n)<<(power+power1))|(2n**power1-1n))&(2n**(power1+power2+1n)-1n);
  const maskdice= mask & dice;
  const rew1 = (maskdice &                                       0b1111111111n)?0n:1n ;
  const rew2 = (maskdice &                       0b11111111111111110000000000n)?0n:1n ;
  const rew3 = (dice     & 0b111111111111111111111100000000000000000000000000n)?0n:1n ;
  const rewardbits = 4n*rew3+2n*rew2+rew1;

  const nullifierHash = await pedersenHash(leBigintToBuffer(terces, 31));

  const leaves = inputs.slice(8, inputs.length).map((l) => hexToBigint(l));
  const tree = await mimicMerkleTree(0n,leaves);
  const merkleProof = tree.path(Number(index));

  // 4. Format witness input to exactly match circuit expectations
  const input = {
    // Public inputs
    root: merkleProof.pathRoot,
    nullifierHash: nullifierHash,
    rewardbits: rewardbits,
    recipient: hexToBigint(inputs[4]),
    relayer: hexToBigint(inputs[5]),
    fee: BigInt(inputs[6]),
    refund: BigInt(inputs[7]),

    // Private inputs
    secret: secret,
    power: power,
    rand: rand,
    pathIndex: index,
    pathElements: merkleProof.pathElements.map((x) => x.toString()),
    //pathIndices: merkleProof.pathIndices,
  };

//console.log(input);

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
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "uint[3]"],
    [
      pA,
      // Swap x coordinates: this is for proof verification with the Solidity precompile for EC Pairings, and not required
      // for verification with e.g. snarkJS.
      [
        [pB[0][1], pB[0][0]],
        [pB[1][1], pB[1][0]],
      ],
      pC,
      [bigintToHex(merkleProof.pathRoot),bigintToHex(nullifierHash),bigintToHex(rewardbits)]
    ]
  );

//console.log(bigintToHex(nullifierHash),"nullifierHash");
//console.log(bigintToHex(rew1),"rew1");
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
