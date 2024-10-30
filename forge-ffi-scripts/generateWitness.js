const { ethers } = require("ethers");
const path = require("path");
const { MerkleTree } = require("fixed-merkle-tree");
const circomlibjs = require("circomlibjs");
const snarkjs = require("snarkjs");

// Intended output: (bytes32 commitment, uint256[2] memory pA, uint256[2][2] memory pB, uint256[2] memory pC, bytes32 root, bytes32 nullifierHash)

////////////////////////////// CONSTANTS ///////////////////////////////////////////

const inputs = process.argv.slice(2, process.argv.length);

// Constants from MerkleTreeWithHistory.sol
const MERKLE_TREE_HEIGHT = 20;

// This matches the zeros function in MerkleTreeWithHistory.sol
const ZERO_VALUES = [
  "2fe54c60d3acabf3343a35b6eba15db4821b340f76e741e2249685ed4899af6c",
  "256a6135777eee2fd26f54b8b7037a25439d5235caee224154186d2b8a52e31d",
  "1151949895e82ab19924de92c40a3d6f7bcb60d92b00504b8199613683f0c200",
  "20121ee811489ff8d61f09fb89e313f14959a0f28bb428a20dba6b0b068b3bdb",
  "0a89ca6ffa14cc462cfedb842c30ed221a50a3d6bf022a6a57dc82ab24c157c9",
  "24ca05c2b5cd42e890d6be94c68d0689f4f21c9cec9c0f13fe41d566dfb54959",
  "1ccb97c932565a92c60156bdba2d08f3bf1377464e025cee765679e604a7315c",
  "19156fbd7d1a8bf5cba8909367de1b624534ebab4f0f79e003bccdd1b182bdb4",
  "261af8c1f0912e465744641409f622d466c3920ac6e5ff37e36604cb11dfff80",
  "0058459724ff6ca5a1652fcbc3e82b93895cf08e975b19beab3f54c217d1c007",
  "1f04ef20dee48d39984d8eabe768a70eafa6310ad20849d4573c3c40c2ad1e30",
  "1bea3dec5dab51567ce7e200a30f7ba6d4276aeaa53e2686f962a46c66d511e5",
  "0ee0f941e2da4b9e31c3ca97a40d8fa9ce68d97c084177071b3cb46cd3372f0f",
  "1ca9503e8935884501bbaf20be14eb4c46b89772c97b96e3b2ebf3a36a948bbd",
  "133a80e30697cd55d8f7d4b0965b7be24057ba5dc3da898ee2187232446cb108",
  "13e6d8fc88839ed76e182c2a779af5b2c0da9dd18c90427a644f7e148a6253b6",
  "1eb16b057a477f4bc8f572ea6bee39561098f78f15bfb3699dcbb7bd8db61854",
  "0da2cb16a1ceaabf1c16b838f7a9e3f2a3a3088d9e0a6debaa748114620696ea",
  "24a3b3d822420b14b5d8cb6c28a574f01e98ea9e940551d2ebd75cee12649f9d",
  "198622acbd783d1b0d9064105b1fc8e4d8889de95c4c519b3f635809fe6afc05",
].map(hexToBigint);

////////////////////////////// UTILS ///////////////////////////////////////////

// Converts a hex string value to Bigint.
function hexToBigint(value) {
  if (typeof value === "string") {
    // If it's a hex string
    if (value.startsWith("0x")) {
      return BigInt(value);
    }
    return BigInt("0x" + value);
  }
  // If it's already a number or BigInt
  return BigInt(value);
}

// Converts a Bigint to hex string of specified length
const bigintToHex = (number, length = 32) =>
  "0x" + number.toString(16).padStart(length * 2, "0");

// Converts a buffer of bytes into a BigInt, assuming little-endian byte order.
const leBufferToBigint = (buff) => {
  let res = 0n;
  for (let i = 0; i < buff.length; i++) {
    const n = BigInt(buff[i]);
    res = res + (n << BigInt(i * 8));
  }
  return res;
};

// Converts a BigInt to a little-endian Buffer of specified byte length.
function leBigintToBuffer(num, byteLength) {
  if (num < 0n) throw new Error("BigInt must be non-negative");

  // Validate that byteLength is sufficient to represent the number
  const requiredLength = Math.ceil(num.toString(2).length / 8);
  if (byteLength < requiredLength) {
    throw new Error(
      `The specified byteLength (${byteLength}) is too small to represent the number`
    );
  }

  const buffer = Buffer.alloc(byteLength);

  // Fill the buffer with bytes from BigInt in little-endian order
  for (let i = 0; i < byteLength; i++) {
    buffer[i] = Number(num & 0xffn); // Get the lowest 8 bits
    num >>= 8n; // Shift by 8 bits to the right
  }

  return buffer;
}

// Computes the Pedersen hash of the given data, returning the result as a BigInt.
const pedersenHash = async (data) => {
  const pedersen = await circomlibjs.buildPedersenHash();

  const pedersenOutput = pedersen.hash(data);

  const babyJubOutput = leBufferToBigint(
    pedersen.babyJub.F.fromMontgomery(
      pedersen.babyJub.unpackPoint(pedersenOutput)[0]
    )
  );
  return babyJubOutput;
};

// Creates a fixed-merkle-tree (just like MerkleTreeWithHistory.sol)
async function initMerkleTree(leaves = []) {
  const pedersen = await circomlibjs.buildPedersenHash();
  const mimcsponge = await circomlibjs.buildMimcSponge();

  const mimcspongeMultiHash = (left, right) =>
    leBufferToBigint(
      pedersen.babyJub.F.fromMontgomery(mimcsponge.multiHash([left, right]))
    );

  return new MerkleTree(MERKLE_TREE_HEIGHT, leaves, {
    hashFunction: mimcspongeMultiHash,
    zeroElement: ZERO_VALUES[0],
  });
}

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  // 1. Get nullifier and secret
  const nullifier = hexToBigint(inputs[0]);
  const secret = hexToBigint(inputs[1]);

  // 2. Get nullifier hash
  const nullifierHash = await pedersenHash(leBigintToBuffer(nullifier, 31));

  // 3. Create merkle tree, insert leaves and get merkle proof for commitment
  const leaves = inputs.slice(6, inputs.length).map((l) => hexToBigint(l));

  const tree = await initMerkleTree(leaves);

  const commitment = await pedersenHash(
    Buffer.concat([
      leBigintToBuffer(nullifier, 31),
      leBigintToBuffer(secret, 31),
    ])
  );
  const merkleProof = tree.proof(commitment);

  // 4. Format witness input to exactly match circuit expectations
  const input = {
    // Public inputs
    root: merkleProof.pathRoot,
    nullifierHash: nullifierHash,
    recipient: hexToBigint(inputs[2]),
    relayer: hexToBigint(inputs[3]),
    fee: BigInt(inputs[4]),
    refund: BigInt(inputs[5]),

    // Private inputs
    nullifier: nullifier,
    secret: secret,
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
    ["uint256[2]", "uint256[2][2]", "uint256[2]", "bytes32", "bytes32"],
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
