#!/bin/cat

# https://github.com/iden3/snarkjs

# generate proof
# snarkjs groth16 fullprove input.json update.wasm update_final.zkey proof.json public.json
snarkjs groth16 fullprove update_input.json update.wasm update_final.zkey proof.json public.json

# verify proof
# snarkjs groth16 verify update_verification_key.json public.json proof.json
snarkjs groth16 verify update_verification_key.json update_public.json update_proof.json
