# Variables
ARTIFACTS_DIR = circuit_artifacts
export NODE_OPTIONS := --max-old-space-size=16000

# Default target
all: setup compile gen_withdraw gen_cancelbet gen_update1 gen_update3 gen_update5 gen_update11 gen_update21 gen_update44 gen_update89 gen_update179 move

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
	circom circuits/update1.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update1_cpp && make all && mv update1 update1.dat ../../groth16/
	@echo "Compiling update3.circom..."
	circom circuits/update3.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update3_cpp && make all && mv update3 update3.dat ../../groth16/
	@echo "Compiling update5.circom..."
	circom circuits/update5.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update5_cpp && make all && mv update5 update5.dat ../../groth16/
	@echo "Compiling update11.circom..."
	circom circuits/update11.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update11_cpp && make all && mv update11 update11.dat ../../groth16/
	@echo "Compiling update21.circom..."
	circom circuits/update21.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update21_cpp && make all && mv update21 update21.dat ../../groth16/
	@echo "Compiling update44.circom..."
	circom circuits/update44.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update44_cpp && make all && mv update44 update44.dat ../../groth16/
	@echo "Compiling update89.circom..."
	circom circuits/update89.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update89_cpp && make all && mv update89 update89.dat ../../groth16/
	@echo "Compiling update179.circom..."
	circom circuits/update179.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update179_cpp && make all && mv update179 update179.dat ../../groth16/

compile_withdraw:
	@echo "Compiling withdraw.circom..."
	circom circuits/withdraw.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_cancelbet:
	@echo "Compiling cancelbet.circom..."
	circom circuits/cancelbet.circom --r1cs --wasm --sym --O2 -o $(ARTIFACTS_DIR)

compile_update1:
	@echo "Compiling update1.circom..."
	circom circuits/update1.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update1_cpp && make all && mv update1 update1.dat ../../groth16/

compile_update3:
	@echo "Compiling update3.circom..."
	circom circuits/update3.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update3_cpp && make all && mv update3 update3.dat ../../groth16/

compile_update5:
	@echo "Compiling update5.circom..."
	circom circuits/update5.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update5_cpp && make all && mv update5 update5.dat ../../groth16/

compile_update11:
	@echo "Compiling update11.circom..."
	circom circuits/update11.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update11_cpp && make all && mv update11 update11.dat ../../groth16/

compile_update21:
	@echo "Compiling update21.circom..."
	circom circuits/update21.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update21_cpp && make all && mv update21 update21.dat ../../groth16/

compile_update44:
	@echo "Compiling update44.circom..."
	circom circuits/update44.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update44_cpp && make all && mv update44 update44.dat ../../groth16/

compile_update89:
	@echo "Compiling update89.circom..."
	circom circuits/update89.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update89_cpp && make all && mv update89 update89.dat ../../groth16/

compile_update179:
	@echo "Compiling update179.circom..."
	circom circuits/update179.circom --r1cs --wasm --sym --O2 -c -o $(ARTIFACTS_DIR) && cd $(ARTIFACTS_DIR)/update179_cpp && make all && mv update179 update179.dat ../../groth16/

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
	snarkjs groth16 setup withdraw.r1cs pot22_final.ptau withdraw_final.zkey && \
	snarkjs zkey export solidityverifier withdraw_final.zkey ../src/Withdraw.sol && sed -i 's/Groth16Verifier/WithdrawG16Verifier/' ../src/Withdraw.sol && \
	snarkjs zkey export verificationkey withdraw_final.zkey withdraw_verification_key.json

# Generate zkey and cancelbet contract
gen_cancelbet:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup cancelbet.r1cs pot10_final.ptau cancelbet_final.zkey && \
	snarkjs zkey export solidityverifier cancelbet_final.zkey ../src/CancelBet.sol && sed -i 's/Groth16Verifier/CancelBetG16Verifier/' ../src/CancelBet.sol && \
	snarkjs zkey export verificationkey cancelbet_final.zkey cancelbet_verification_key.json

# Generate zkey and update contract
gen_update1:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update1.r1cs pot22_final.ptau update1_final.zkey && \
	snarkjs zkey export solidityverifier update1_final.zkey ../src/Update1.sol && sed -i 's/Groth16Verifier/Update1G16Verifier/' ../src/Update1.sol && \
	snarkjs zkey export verificationkey update1_final.zkey update1_verification_key.json

# Generate zkey and update contract
gen_update3:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update3.r1cs pot22_final.ptau update3_final.zkey && \
	snarkjs zkey export solidityverifier update3_final.zkey ../src/Update3.sol && sed -i 's/Groth16Verifier/Update3G16Verifier/' ../src/Update3.sol && \
	snarkjs zkey export verificationkey update3_final.zkey update3_verification_key.json

# Generate zkey and update contract
gen_update5:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update5.r1cs pot22_final.ptau update5_final.zkey && \
	snarkjs zkey export solidityverifier update5_final.zkey ../src/Update5.sol && sed -i 's/Groth16Verifier/Update5G16Verifier/' ../src/Update5.sol && \
	snarkjs zkey export verificationkey update5_final.zkey update5_verification_key.json

# Generate zkey and update contract
gen_update11:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update11.r1cs pot22_final.ptau update11_final.zkey && \
	snarkjs zkey export solidityverifier update11_final.zkey ../src/Update11.sol && sed -i 's/Groth16Verifier/Update11G16Verifier/' ../src/Update11.sol && \
	snarkjs zkey export verificationkey update11_final.zkey update11_verification_key.json

# Generate zkey and update contract
gen_update21:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update21.r1cs pot22_final.ptau update21_final.zkey && \
	snarkjs zkey export solidityverifier update21_final.zkey ../src/Update21.sol && sed -i 's/Groth16Verifier/Update21G16Verifier/' ../src/Update21.sol && \
	snarkjs zkey export verificationkey update21_final.zkey update21_verification_key.json

# Generate zkey and update contract
gen_update44:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update44.r1cs pot22_final.ptau update44_final.zkey && \
	snarkjs zkey export solidityverifier update44_final.zkey ../src/Update44.sol && sed -i 's/Groth16Verifier/Update44G16Verifier/' ../src/Update44.sol && \
	snarkjs zkey export verificationkey update44_final.zkey update44_verification_key.json

# Generate zkey and update contract
gen_update89:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update89.r1cs pot22_final.ptau update89_final.zkey && \
	snarkjs zkey export solidityverifier update89_final.zkey ../src/Update89.sol && sed -i 's/Groth16Verifier/Update89G16Verifier/' ../src/Update89.sol && \
	snarkjs zkey export verificationkey update89_final.zkey update89_verification_key.json

# Generate zkey and update contract
gen_update179:
	cd $(ARTIFACTS_DIR) && \
	snarkjs groth16 setup update179.r1cs pot23_final.ptau update179_final.zkey && \
	snarkjs zkey export solidityverifier update179_final.zkey ../src/Update179.sol && sed -i 's/Groth16Verifier/Update179G16Verifier/' ../src/Update179.sol && \
	snarkjs zkey export verificationkey update179_final.zkey update179_verification_key.json

move:
	cd $(ARTIFACTS_DIR) && \
        mv cancelbet_final.zkey update21_final.zkey update89_final.zkey update179_final.zkey update11_final.zkey update44_final.zkey withdraw_final.zkey update1_final.zkey update3_final.zkey update5_final.zkey cancelbet_js/cancelbet.wasm update44_js/update44.wasm update11_js/update11.wasm update3_js/update3.wasm update5_js/update5.wasm update1_js/update1.wasm update179_js/update179.wasm update179_js/update179.wasm update21_js/update21.wasm withdraw_js/withdraw.wasm ../groth16/

# Clean circuit_artifacts
clean:
	rm -rf $(ARTIFACTS_DIR)
