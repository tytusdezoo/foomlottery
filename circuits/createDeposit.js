const fs = require("fs");
const path = require("path");

const { buildBabyjub, buildPedersenHash } = require("circomlibjs");
const {
  createThirdwebClient,
  getContract,
  getContractEvents,
  uint8ArrayToHex,
} = require("thirdweb");

// const client = createThirdwebClient({ secretKey: process.env.SECRET_KEY });
// const targetContract = getContract({
//   client,
//   chain: 31337,
//   address: "0x123...",
// });

/** Generates a random bigint of the specified number of bytes */
function generateRandomBigInt(numBytes) {
  // Create an array of the specified number of random bytes
  const bytes = new Uint8Array(numBytes);
  crypto.getRandomValues(bytes);

  // Convert bytes to hex string
  let hexString = Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");

  // Create BigInt from hex string
  return BigInt("0x" + hexString);
}

/** Converts a bigint to a buffer of specified number of bytes */
function bigintToBytes(bigint, numBytes) {
  if (bigint < 0n) {
    throw new Error("Negative values not supported");
  }

  // Calculate maximum value for given number of bytes
  const maxValue = 2n ** (BigInt(numBytes) * 8n) - 1n;

  if (bigint > maxValue) {
    throw new Error(`Value exceeds maximum for ${numBytes} bytes`);
  }

  // Convert to hex and pad with zeros
  let hex = bigint.toString(16);
  // Ensure even length for Buffer.from
  hex = hex.padStart(numBytes * 2, "0");

  // If hex is longer than needed (shouldn't happen due to above check)
  if (hex.length > numBytes * 2) {
    hex = hex.slice(-numBytes * 2);
  }

  return Buffer.from(hex, "hex");
}

/** Compute pedersen hash */
const pedersenHash = async (data) => {
  const pedersenHash = await buildPedersenHash();
  const babyJub = await buildBabyjub();

  return babyJub.unpackPoint(pedersenHash.hash(data))[0];
};

/** Creates a deposit object */
async function createDeposit({ nullifier, secret }) {
  const deposit = { nullifier, secret };
  deposit.preimage = Buffer.concat([
    bigintToBytes(nullifier, 31),
    bigintToBytes(secret, 31),
  ]);
  deposit.commitment = await pedersenHash(deposit.preimage);
  deposit.commitmentHex = uint8ArrayToHex(deposit.commitment);
  deposit.nullifierHash = await pedersenHash(bigintToBytes(nullifier, 31));
  deposit.nullifierHashHex = uint8ArrayToHex(deposit.nullifierHash);
  return deposit;
}

// async function generateMerkleProof(deposit) {
//   console.log("Getting contract state...");

//   const events = await getContractEvents({
//     contract: targetContract,
//     fromBlock: 123456n,
//     toBlock: 123456n,
//     events: [preparedEvent, preparedEvent2],
//   });

//   const events = await contract.getPastEvents("Deposit", {
//     fromBlock: 0,
//     toBlock: "latest",
//   });
//   const leaves = events
//     .sort((a, b) => a.returnValues.leafIndex - b.returnValues.leafIndex) // Sort events in chronological order
//     .map((e) => e.returnValues.commitment);
//   const tree = new merkleTree(MERKLE_TREE_HEIGHT, leaves);

//   // Find current commitment in the tree
//   let depositEvent = events.find(
//     (e) => e.returnValues.commitment === toHex(deposit.commitment)
//   );
//   let leafIndex = depositEvent ? depositEvent.returnValues.leafIndex : -1;

//   // Validate that our data is correct (optional)
//   const isValidRoot = await contract.methods
//     .isKnownRoot(toHex(tree.root()))
//     .call();
//   const isSpent = await contract.methods
//     .isSpent(toHex(deposit.nullifierHash))
//     .call();
//   assert(isValidRoot === true, "Merkle tree is corrupted");
//   assert(isSpent === false, "The note is already spent");
//   assert(leafIndex >= 0, "The deposit is not found in the tree");

//   // Compute merkle proof of our commitment
//   const { pathElements, pathIndices } = tree.path(leafIndex);
//   return { pathElements, pathIndices, root: tree.root() };
// }

async function main() {
  const deposit = await createDeposit({
    nullifier: generateRandomBigInt(31),
    secret: generateRandomBigInt(31),
  });

  const input = {
    // Public snark inputs
    root: deposit.commitmentHex,
    nullifierHash: deposit.nullifierHashHex,
    recipient: 0,
    relayer: 0,
    fee: 0,
    refund: 0,

    // Private snark inputs
    nullifier: deposit.nullifier.toString(),
    secret: deposit.secret.toString(),
    pathElements: [
      "0x2fe54c60d3acabf3343a35b6eba15db4821b340f76e741e2249685ed4899af6c", // zeros(0)
      "0x256a6135777eee2fd26f54b8b7037a25439d5235caee224154186d2b8a52e31d", // zeros(1)
      "0x1151949895e82ab19924de92c40a3d6f7bcb60d92b00504b8199613683f0c200", // zeros(2)
      "0x20121ee811489ff8d61f09fb89e313f14959a0f28bb428a20dba6b0b068b3bdb", // zeros(3)
      "0x0a89ca6ffa14cc462cfedb842c30ed221a50a3d6bf022a6a57dc82ab24c157c9", // zeros(4)
      "0x24ca05c2b5cd42e890d6be94c68d0689f4f21c9cec9c0f13fe41d566dfb54959", // zeros(5)
      "0x1ccb97c932565a92c60156bdba2d08f3bf1377464e025cee765679e604a7315c", // zeros(6)
      "0x19156fbd7d1a8bf5cba8909367de1b624534ebab4f0f79e003bccdd1b182bdb4", // zeros(7)
      "0x261af8c1f0912e465744641409f622d466c3920ac6e5ff37e36604cb11dfff80", // zeros(8)
      "0x0058459724ff6ca5a1652fcbc3e82b93895cf08e975b19beab3f54c217d1c007", // zeros(9)
      "0x1f04ef20dee48d39984d8eabe768a70eafa6310ad20849d4573c3c40c2ad1e30", // zeros(10)
      "0x1bea3dec5dab51567ce7e200a30f7ba6d4276aeaa53e2686f962a46c66d511e5", // zeros(11)
      "0x0ee0f941e2da4b9e31c3ca97a40d8fa9ce68d97c084177071b3cb46cd3372f0f", // zeros(12)
      "0x1ca9503e8935884501bbaf20be14eb4c46b89772c97b96e3b2ebf3a36a948bbd", // zeros(13)
      "0x133a80e30697cd55d8f7d4b0965b7be24057ba5dc3da898ee2187232446cb108", // zeros(14)
      "0x13e6d8fc88839ed76e182c2a779af5b2c0da9dd18c90427a644f7e148a6253b6", // zeros(15)
      "0x1eb16b057a477f4bc8f572ea6bee39561098f78f15bfb3699dcbb7bd8db61854", // zeros(16)
      "0x0da2cb16a1ceaabf1c16b838f7a9e3f2a3a3088d9e0a6debaa748114620696ea", // zeros(17)
      "0x24a3b3d822420b14b5d8cb6c28a574f01e98ea9e940551d2ebd75cee12649f9d", // zeros(18)
      "0x198622acbd783d1b0d9064105b1fc8e4d8889de95c4c519b3f635809fe6afc05", // zeros(19)
    ],

    pathIndices: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // 20 zeros
  };

  // Write to input.json in the same directory
  const filePath = path.join(__dirname, "input.json");
  fs.writeFileSync(filePath, JSON.stringify(input, null, 2));

  console.log("Deposit data written to input.json");
  console.log(input);
}

main();
