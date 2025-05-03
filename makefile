# Variables
ARTIFACTS_DIR = circuit_artifacts

# Default target
all: setup compile ptau gen_withdraw get_cancelbet

# Create necessary directories
setup:
	mkdir -p $(ARTIFACTS_DIR)

# Compile withdraw.circom
compile:
	@echo "Compiling withdraw.circom..."
	circom circuits/withdraw.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling cancelbet.circom..."
	circom circuits/cancelbet.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

# Powers of tau ceremony
ptau:
	@echo "Performing powers of tau ceremony..."
	cd $(ARTIFACTS_DIR) && \
	snarkjs powersoftau new bn128 16 pot16_0000.ptau -v && \
	snarkjs powersoftau contribute pot16_0000.ptau pot16_0001.ptau --name="First contribution" -v && \
	snarkjs powersoftau prepare phase2 pot16_0001.ptau pot16_final.ptau -v

# Generate zkey and withdraw contract
gen_withdraw:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup withdraw.r1cs pot16_final.ptau withdraw_final.zkey && \
	snarkjs zkey export solidityverifier withdraw_final.zkey ../src/Withdraw.sol && sed -i 's/Groth16Verifier/WithdrawG16Verifier/' ../src/Withdraw.sol && \
	snarkjs zkey export verificationkey withdraw_final.zkey withdraw_verification_key.json

# Generate zkey and cancelbet contract
gen_cancelbet:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup cancelbet.r1cs pot16_final.ptau cancelbet_final.zkey && \
	snarkjs zkey export solidityverifier cancelbet_final.zkey ../src/CancelBet.sol && sed -i 's/Groth16Verifier/CancelBetG16Verifier/' ../src/CancelBet.sol && \
	snarkjs zkey export verificationkey cancelbet_final.zkey cancelbet_verification_key.json

# Clean circuit_artifacts
clean:
	rm -rf $(ARTIFACTS_DIR)
