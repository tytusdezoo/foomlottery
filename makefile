# Variables
ARTIFACTS_DIR = circuit_artifacts
# export NODE_OPTIONS="--max-old-space-size=4096"
export NODE_OPTIONS := --max-old-space-size=4096

# Default target
all: setup compile gen_withdraw gen_cancelbet gen_update22

# Create necessary directories
setup:
	mkdir -p $(ARTIFACTS_DIR)

# Compile withdraw.circom
compile:
	@echo "Compiling withdraw.circom..."
	circom circuits/withdraw.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling cancelbet.circom..."
	circom circuits/cancelbet.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling update2.circom..."
	circom circuits/update2.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling update6.circom..."
	circom circuits/update6.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling update22.circom..."
	circom circuits/update22.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling update44.circom..."
	circom circuits/update44.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling update45.circom..."
	circom circuits/update45.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_cancelbet:
	@echo "Compiling cancelbet.circom..."
	circom circuits/cancelbet.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_update2:
	@echo "Compiling update2.circom..."
	circom circuits/update2.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_update6:
	@echo "Compiling update6.circom..."
	circom circuits/update6.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_update22:
	@echo "Compiling update22.circom..."
	circom circuits/update22.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_update44:
	@echo "Compiling update44.circom..."
	circom circuits/update44.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_update45:
	@echo "Compiling update45.circom..."
	circom circuits/update45.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

# Powers of tau ceremony
ptau16:
	@echo "Performing powers of tau ceremony..."
	cd $(ARTIFACTS_DIR) && \
	snarkjs powersoftau new bn128 16 pot16_0000.ptau -v && \
	snarkjs powersoftau contribute pot16_0000.ptau pot16_0001.ptau --name="First contribution" -v && \
	snarkjs powersoftau prepare phase2 pot16_0001.ptau pot16_final.ptau -v

ptau20:
	@echo "Performing powers of tau ceremony..."
	cd $(ARTIFACTS_DIR) && \
	snarkjs powersoftau new bn128 20 pot20_0000.ptau -v && \
	snarkjs powersoftau contribute pot20_0000.ptau pot20_0001.ptau --name="First contribution" -v && \
	snarkjs powersoftau prepare phase2 pot20_0001.ptau pot20_final.ptau -v


# Generate zkey and withdraw contract
gen_withdraw:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup withdraw.r1cs pot20_final.ptau withdraw_final.zkey && \
	snarkjs zkey export solidityverifier withdraw_final.zkey ../src/Withdraw.sol && sed -i 's/Groth16Verifier/WithdrawG16Verifier/' ../src/Withdraw.sol && \
	snarkjs zkey export verificationkey withdraw_final.zkey withdraw_verification_key.json

# Generate zkey and cancelbet contract
gen_cancelbet:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup cancelbet.r1cs pot20_final.ptau cancelbet_final.zkey && \
	snarkjs zkey export solidityverifier cancelbet_final.zkey ../src/CancelBet.sol && sed -i 's/Groth16Verifier/CancelBetG16Verifier/' ../src/CancelBet.sol && \
	snarkjs zkey export verificationkey cancelbet_final.zkey cancelbet_verification_key.json

# Generate zkey and update contract
gen_update2:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update2.r1cs pot20_final.ptau update2_final.zkey && \
	snarkjs zkey export solidityverifier update2_final.zkey ../src/Update2.sol && sed -i 's/Groth16Verifier/Update2G16Verifier/' ../src/Update2.sol && \
	snarkjs zkey export verificationkey update2_final.zkey update2_verification_key.json

# Generate zkey and update contract
gen_update6:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update6.r1cs pot20_final.ptau update6_final.zkey && \
	snarkjs zkey export solidityverifier update6_final.zkey ../src/Update6.sol && sed -i 's/Groth16Verifier/Update6G16Verifier/' ../src/Update6.sol && \
	snarkjs zkey export verificationkey update6_final.zkey update6_verification_key.json

# Generate zkey and update contract
gen_update22:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update22.r1cs pot20_final.ptau update22_final.zkey && \
	snarkjs zkey export solidityverifier update22_final.zkey ../src/Update22.sol && sed -i 's/Groth16Verifier/Update22G16Verifier/' ../src/Update22.sol && \
	snarkjs zkey export verificationkey update22_final.zkey update22_verification_key.json

# Generate zkey and update contract
gen_update44:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update44.r1cs pot21_final.ptau update44_final.zkey && \
	snarkjs zkey export solidityverifier update44_final.zkey ../src/Update44.sol && sed -i 's/Groth16Verifier/Update44G16Verifier/' ../src/Update44.sol && \
	snarkjs zkey export verificationkey update44_final.zkey update44_verification_key.json

# Generate zkey and update contract
gen_update45:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update45.r1cs pot21_final.ptau update45_final.zkey && \
	snarkjs zkey export solidityverifier update45_final.zkey ../src/Update45.sol && sed -i 's/Groth16Verifier/Update45G16Verifier/' ../src/Update45.sol && \
	snarkjs zkey export verificationkey update45_final.zkey update45_verification_key.json

# Clean circuit_artifacts
clean:
	rm -rf $(ARTIFACTS_DIR)
