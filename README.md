# Tornado Cash [Re-built]

Tornado Cash is a non-custodial Ethereum and ERC20 privacy solution based on zkSNARKs.

This repository re-builds Tornado Cash for **educational purposes** as a [Foundry](https://book.getfoundry.sh/) project, and uses the latest versions of Circom ([circomlib](https://github.com/iden3/circomlib) and [circomlibjs](https://github.com/iden3/circomlibjs)) and [snarkJS](https://github.com/iden3/snarkjs) to generate proofs.

The ([original-repository](https://github.com/tornadocash/tornado-core)) is built with older versions of tools, and it is difficult to use it as educational reference material to understand the latest Solidity <-> Circom workflow for writing smart contracts with ZK-SNARK capabilities.

## Installation

Clone this repository

```bash
git clone https://github.com/nkrishang/tornado-cash-rebuilt.git
```

Install dependencies:

```bash
forge install
```

```bash
yarn
```

## Usage

### Compiling circom circuits

The main workflow of this repo is:

1. Compile circuits to generate circuit artifacts (e.g. r1cs file, ...)
2. Perform a powers of tau ceremony
3. Generate zkey and verifier Solidity smart contract

These three steps are written as bash commands in the [makefile](https://github.com/nkrishang/tornado-cash-rebuilt/blob/main/makefile). Run the following to perform these steps:

```bash
make all
```

This will create a `/circuit_artifacts` folder that contains everything needed to run tests.

### Running tests

There is a single forge test file `/test/ETHTornado.t.sol` and scripts used in this test `/forge-ffi-scripts`. The test and script files are annotated.

Run the following command to run tests (_after_ you have generated circuit artifacts):

```bash
forge test
```

## Credits

For a comprehensive understanding of ZK-SNARKs, see the Rareskills [ZK Book](https://www.rareskills.io/zk-book) and their [article](https://www.rareskills.io/post/how-does-tornado-cash-work) on how Tornado Cash works.
