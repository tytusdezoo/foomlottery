#!/usr/bin/node
const path = require("path");
const snarkjs = require("snarkjs");
const { ethers } = require("ethers");
const { hexToBigint, bigintToHex, leBigintToBuffer, reverseBits, } = require("./utils/bigint.js");
const { pedersenHash } = require("./utils/pedersen.js");
const { mimcsponge3 } = require("./utils/mimcsponge.js");
const { getPath, findIndex } = require("./utils/mimcMerkleTree.js");

////////////////////////////// MAIN ///////////////////////////////////////////
// forge-ffi-scripts/withdraw.js 0x4229f5eb2109ba8e3a1c4134720bda5a1d4070f1086fa128a1d630576a67fa0a 0x0000000000000000000000000000000000000000000000000000000000000002 0x0000000000000000000000000000000000000001 0x0000000000000000000000000000000000000000 0x0 0x0

async function main() {
  const inputs = process.argv.slice(2, process.argv.length);
  const secret_power = hexToBigint(inputs[0]); // TODO: compute hash and read from www
  const secret = secret_power>>8n;
  const power = secret_power & 0x1fn;
  const hash = await pedersenHash(leBigintToBuffer(secret, 31));
  const hash_power1 = hash + power + 1n;
  const startindex = parseInt(inputs[1].replace(/^0x0*/, ''),16); // could be int instead of hex later
  const [index,rand] = findIndex(hash_power1,startindex);
  if(index>0 && rand==0){
    throw("bet not processed yet");}
  if(!index){
    throw("bet not found");}
  const bigindex = BigInt(index);
  const dice = await mimcsponge3(secret,rand,bigindex);

  // 1.5. calculate reward
  const power1=10n;
  const power2=16n;
  const power3=22n;
  const mask = (power<=power1)?(((2n**(power1+power2+power3+1n)-1n)<<(power              ))                         )&(2n**(power1+power2+power3+1n)-1n) :
              ((power<=power2)?(((2n**(       power2+power3+1n)-1n)<<(power+power1       ))|(2n**(power1       )-1n))&(2n**(power1+power2+power3+1n)-1n) :
			       (((2n**(              power3+1n)-1n)<<(power+power1+power2))|(2n**(power1+power2)-1n))&(2n**(power1+power2+power3+1n)-1n));
  const maskdice= mask & dice;
  const rew1 = (maskdice &                                       0b1111111111n)?0n:1n ;
  const rew2 = (maskdice &                       0b11111111111111110000000000n)?0n:1n ;
  const rew3 = (maskdice & 0b111111111111111111111100000000000000000000000000n)?0n:1n ;
  const rewardbits = 4n*rew3+2n*rew2+rew1;

  const terces = reverseBits(dice,31*8);
  const nullifierHash = await pedersenHash(leBigintToBuffer(terces, 31));

  const pathElements = await getPath(index);

  // 4. Format witness input to exactly match circuit expectations
  const input = {
    // Public inputs
    root: pathElements[32],
    nullifierHash: nullifierHash,
    rewardbits: rewardbits,
    recipient: hexToBigint(inputs[2]),
    relayer: hexToBigint(inputs[3]),
    fee: hexToBigint(inputs[4]),
    refund: hexToBigint(inputs[5]),
    // Private inputs
    secret: secret,
    power: power,
    rand: rand,
    pathIndex: BigInt(index),
    pathElements: pathElements.slice(0,32),
  };

  // 5. Create groth16 proof for witness
  const { proof } = await snarkjs.groth16.fullProve(
    input,
    path.join(__dirname, "../groth16/withdraw.wasm"),
    path.join(__dirname, "../groth16/withdraw_final.zkey")
  );

  const pA = proof.pi_a.slice(0, 2);
  const pB = proof.pi_b.slice(0, 2);
  const pC = proof.pi_c.slice(0, 2);

  // 6. Return abi encoded witness
  const witness = ethers.AbiCoder.defaultAbiCoder().encode(
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "uint[7]"],
    [
      pA,
      // Swap x coordinates: this is for proof verification with the Solidity precompile for EC Pairings, and not required
      // for verification with e.g. snarkJS.
      [
        [pB[0][1], pB[0][0]],
        [pB[1][1], pB[1][0]],
      ],
      pC,
      [
      bigintToHex(pathElements[32]),
      bigintToHex(nullifierHash),
      bigintToHex(rewardbits),
      inputs[2],
      inputs[3],
      inputs[4],
      inputs[5]
      ]
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
