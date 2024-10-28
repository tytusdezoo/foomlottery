# Variables
PTAU = 12
BUILD_DIR = build
PTAU_DIR = ptau
CONTRACTS_DIR = contracts

# Default target
all: setup compile witness prove verify

# Create necessary directories
setup:
	mkdir -p $(BUILD_DIR)
	mkdir -p $(CONTRACTS_DIR)

# Compile withdraw.circom
compile:
	@echo "Compiling withdraw.circom..."
	circom withdraw.circom --r1cs --wasm --sym -o ./$(BUILD_DIR)

# Download PTAU file if it doesn't exist
download_ptau:
	@if [ ! -f ./$(PTAU_DIR)/powersOfTau28_hez_final_$(PTAU).ptau ]; then \
		echo "----- Download powersOfTau28_hez_final_$(PTAU).ptau -----"; \
		wget -P ./$(PTAU_DIR) https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_$(PTAU).ptau; \
	else \
		echo "----- powersOfTau28_hez_final_$(PTAU).ptau already exists -----"; \
	fi

# Generate witness
witness:
	# Copy the input file inside the withdraw_js directory
	cp input.json withdraw_js/input.json
	
	# Go inside the withdraw_js directory and generate the witness.wtns
	cd withdraw_js && node generate_witness.js Mul.wasm input.json witness.wtns
	
	# Copy the witness.wtns to the outside
	cp withdraw_js/witness.wtns witness.wtns

# Generate proof
prove: download_ptau
	# Start a new powers of tau ceremony
	snarkjs powersoftau new bn128 14 pot12_0000.ptau -v
	
	# Contribute to the ceremony
	snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
	
	# Start generating th phase 2
	snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
	
	# Generate a .zkey file that will contain the proving and verification keys together with all phase 2 contributions
	snarkjs groth16 setup Mul.r1cs pot12_final.ptau Mul_0000.zkey
	
	# Contribute to the phase 2 of the ceremony
	snarkjs zkey contribute Mul_0000.zkey Mul_0001.zkey --name="1st Contributor Name" -v
	
	# Export the verification key
	snarkjs zkey export verificationkey Mul_0001.zkey verification_key.json
	
	# Generate a zk-proof associated to the circuit and the witness. This generates proof.json and public.json
	snarkjs groth16 prove Mul_0001.zkey witness.wtns proof.json public.json

# Verify the proof
verify:
	# Verify the proof
	snarkjs groth16 verify verification_key.json public.json proof.json
	
	# Generate a Solidity verifier that allows verifying proofs on Ethereum blockchain
	snarkjs zkey export solidityverifier Mul_0001.zkey ./$(CONTRACTS_DIR)/verifier.sol
	
	# Generate and print parameters of call
	snarkjs generatecall | tee parameters.txt

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR)
	rm -rf $(CONTRACTS_DIR)
	rm -f *.ptau
	rm -f *.zkey
	rm -f verification_key.json
	rm -f proof.json
	rm -f public.json
	rm -f parameters.txt
	rm -f witness.wtns

.PHONY: all setup compile download_ptau witness prove verify clean