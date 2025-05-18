# Variables
ARTIFACTS_DIR = circuit_artifacts
# export NODE_OPTIONS="--max-old-space-size=4096"
export NODE_OPTIONS := --max-old-space-size=4096

# Default target
all: setup compile gen_withdraw gen_cancelbet gen_update1 gen_update5 gen_update21 gen_update44

# Create necessary directories
setup:
	mkdir -p $(ARTIFACTS_DIR)

# Compile withdraw.circom
compile:
	@echo "Compiling withdraw.circom..."
	circom circuits/withdraw.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling cancelbet.circom..."
	circom circuits/cancelbet.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling update1.circom..."
	circom circuits/update1.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling update5.circom..."
	circom circuits/update5.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling update21.circom..."
	circom circuits/update21.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)
	@echo "Compiling update44.circom..."
	circom circuits/update44.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_cancelbet:
	@echo "Compiling cancelbet.circom..."
	circom circuits/cancelbet.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_update1:
	@echo "Compiling update1.circom..."
	circom circuits/update1.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_update5:
	@echo "Compiling update5.circom..."
	circom circuits/update5.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_update21:
	@echo "Compiling update21.circom..."
	circom circuits/update21.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_update44:
	@echo "Compiling update44.circom..."
	circom circuits/update44.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

# Powers of tau ceremony
ptau10:
	@echo "Performing powers of tau ceremony..."
	cd $(ARTIFACTS_DIR) && \
	snarkjs powersoftau new bn128 10 pot10_0000.ptau -v && \
	snarkjs powersoftau contribute pot10_0000.ptau pot10_0001.ptau --name="First contribution" -v && \
	snarkjs powersoftau prepare phase2 pot10_0001.ptau pot10_final.ptau -v

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

ptau22:
	@echo "Performing powers of tau ceremony..."
	cd $(ARTIFACTS_DIR) && \
	snarkjs powersoftau new bn128 22 pot22_0000.ptau -v && \
	snarkjs powersoftau contribute pot22_0000.ptau pot22_0001.ptau --name="First contribution" -v && \
	snarkjs powersoftau prepare phase2 pot22_0001.ptau pot22_final.ptau -v

ptau23:
	@echo "Performing powers of tau ceremony..."
	cd $(ARTIFACTS_DIR) && \
	snarkjs powersoftau new bn128 23 pot23_0000.ptau -v && \
	snarkjs powersoftau contribute pot23_0000.ptau pot23_0001.ptau --name="First contribution" -v && \
	snarkjs powersoftau prepare phase2 pot23_0001.ptau pot23_final.ptau -v



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
gen_update1:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update1.r1cs pot20_final.ptau update1_final.zkey && \
	snarkjs zkey export solidityverifier update1_final.zkey ../src/Update1.sol && sed -i 's/Groth16Verifier/Update1G16Verifier/' ../src/Update1.sol && \
	snarkjs zkey export verificationkey update1_final.zkey update1_verification_key.json

# Generate zkey and update contract
gen_update5:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update5.r1cs pot20_final.ptau update5_final.zkey && \
	snarkjs zkey export solidityverifier update5_final.zkey ../src/Update5.sol && sed -i 's/Groth16Verifier/Update5G16Verifier/' ../src/Update5.sol && \
	snarkjs zkey export verificationkey update5_final.zkey update5_verification_key.json

# Generate zkey and update contract
gen_update21:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update21.r1cs pot20_final.ptau update21_final.zkey && \
	snarkjs zkey export solidityverifier update21_final.zkey ../src/Update21.sol && sed -i 's/Groth16Verifier/Update21G16Verifier/' ../src/Update21.sol && \
	snarkjs zkey export verificationkey update21_final.zkey update21_verification_key.json

# Generate zkey and update contract
gen_update44:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update44.r1cs pot21_final.ptau update44_final.zkey && \
	snarkjs zkey export solidityverifier update44_final.zkey ../src/Update44.sol && sed -i 's/Groth16Verifier/Update44G16Verifier/' ../src/Update44.sol && \
	snarkjs zkey export verificationkey update44_final.zkey update44_verification_key.json

# Clean circuit_artifacts
clean:
	rm -rf $(ARTIFACTS_DIR)
