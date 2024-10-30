const { ethers } = require("ethers");
const { randomBytes } = require("crypto");
const circomlibjs = require("circomlibjs");

// Intended output: (bytes32 commitment, bytes32 nullifier, bytes32 secret)

////////////////////////////// UTILS ///////////////////////////////////////////

// Converts a Bigint to hex string of specified length
const bigintToHex = (number, length = 32) =>
  "0x" + number.toString(16).padStart(length * 2, "0");

// Generates a random BigInt of specified byte length
const rbigint = (nbytes) => leBufferToBigint(randomBytes(nbytes));

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

////////////////////////////// MAIN ///////////////////////////////////////////

async function main() {
  // 1. Generate random nullifier and secret
  const nullifier = rbigint(31);
  const secret = rbigint(31);

  // 2. Get commitment
  const commitment = await pedersenHash(
    Buffer.concat([
      leBigintToBuffer(nullifier, 31),
      leBigintToBuffer(secret, 31),
    ])
  );

  // 3. Return abi encoded nullifier, secret, commitment
  const res = ethers.AbiCoder.defaultAbiCoder().encode(
    ["bytes32", "bytes32", "bytes32"],
    [bigintToHex(commitment), bigintToHex(nullifier), bigintToHex(secret)]
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
