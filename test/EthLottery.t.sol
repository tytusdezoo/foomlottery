// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {WithdrawG16Verifier} from "src/Withdraw.sol";
import {CancelBetG16Verifier} from "src/CancelBet.sol";
import {IWithdraw, ICancel, IHasher} from "src/FoomLottery.sol";
import {EthLottery} from "src/EthLottery.sol";

contract EthLotteryTest is Test {
    uint256 public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    EthLottery public lottery;
    IWithdraw public withdraw;
    ICancel public cancel;

    // Test vars
    address public constant recipient = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant relayer = address(0);
    uint256 public constant fee = 0;
    uint256 public constant refund = 0;

    uint public constant betMin = 1; // TODO: compute correct value
    uint public constant betPower1 = 10; // power of the first bet = 1024
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304


    function deployMimcSponge(bytes memory bytecode) public returns (address) {
        address deployedAddress;
        assembly {
            deployedAddress := create(0, add(bytecode, 0x20), mload(bytecode))
            if iszero(deployedAddress) { revert(0, 0) }
        }
        return deployedAddress;
    }

    function setUp() public {
        // Deploy MimcSponge hasher contract.
        string[] memory inputs = new string[](3);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/deployMimcsponge.js";
        bytes memory mimcspongeBytecode = vm.ffi(inputs);
        address mimcHasher;
        assembly {
            mimcHasher := create(0, add(mimcspongeBytecode, 0x20), mload(mimcspongeBytecode))
            if iszero(mimcHasher) { revert(0, 0) }
        }

        // Deploy Groth16 verifier contracts.
        withdraw = IWithdraw(address(new WithdrawG16Verifier()));
        cancel = ICancel(address(new CancelBetG16Verifier()));

        // Deploy lottery contract.
        lottery = new EthLottery(withdraw, cancel, IHasher(mimcHasher), 0, betMin);
    }

    function _getWitnessAndProof(
        bytes32 _secret,
        bytes32 _mask,
        bytes32 _rand,
        address _recipient,
        address _relayer,
        bytes32[] memory leaves
    ) internal returns (uint256[2] memory, uint256[2][2] memory, uint256[2] memory, bytes32, bytes32, uint, uint, uint) {
        string[] memory inputs = new string[](8 + leaves.length);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/generateWitness.js";
        inputs[2] = vm.toString(_secret);
        inputs[3] = vm.toString(_mask);
        inputs[4] = vm.toString(_rand);
        inputs[5] = vm.toString(_recipient);
        inputs[6] = vm.toString(_relayer);
        inputs[7] = "0";
        inputs[8] = "0";

        for (uint256 i = 0; i < leaves.length; i++) {
            inputs[9 + i] = vm.toString(leaves[i]);
        }

        bytes memory result = vm.ffi(inputs);
        (uint256[2] memory pA, uint256[2][2] memory pB, uint256[2] memory pC, bytes32 root, bytes32 nullifierHash, uint rew1, uint rew2, uint rew3) =
            abi.decode(result, (uint256[2], uint256[2][2], uint256[2], bytes32, bytes32, uint, uint, uint));

        return (pA, pB, pC, root, nullifierHash, rew1, rew2, rew3);
    }

    function _getCommitment() internal returns (bytes32 commitment, bytes32 secret) {
        string[] memory inputs = new string[](2);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/generateCommitment.js";

        bytes memory result = vm.ffi(inputs);
        (commitment, secret) = abi.decode(result, (bytes32, bytes32));

        return (commitment, secret);
    }

    function _play_and_get_data() internal returns (uint,bytes32,bytes32,uint,uint,uint) {
        uint _amount=3;
        // 1. Generate commitment and deposit
        (bytes32 commitment, bytes32 secret) = _getCommitment();
        (uint mask) = lottery.getMask(_amount*betMin);
        lottery.play{value: _amount*betMin}(commitment,0);
	// 1.5. Process bets by admin
        (uint betsIndex, uint commitCount, uint commitBlock,uint commitHash)=lottery.getStatus();
        assertEq(commitBlock,0);
        uint _revealSecret = uint(keccak256(commitCount));
        uint _commitHash = uint(keccak256(_revealSecret));
        lottery.commit(_commitHash);
	/* must wait for the transaction to get included in a block */
        uint commitCountNew;
        (betsIndex, commitCountNew, commitBlock,commitHash)=lottery.getStatus();
        assertEq(commitHash,genhash);
        assertEq(commitCount+1,commitCountNew);
        (uint rand,uint leaf)=lottery.reveal(_revealSecret);
        (betsIndex, commitCount, commitBlock,commitHash)=lottery.getStatus();
        assertEq(commitBlock,0);
        return(_amount,commitment,secret,mask,rand,leaf);
    }

    function _collect(uint _amount,bytes32 commitment,bytes32 secret,uint mask,uint rand,bytes32[] memory leaves) internal {
        (uint256[2] memory pA, uint256[2][2] memory pB, uint256[2] memory pC, bytes32 root, bytes32 nullifierHash, uint rew1, uint rew2, uint rew3) =
            _getWitnessAndProof(secret, mask, rand, recipient, relayer, leaves);
        uint _reward = betMin * rew1 * 2**betPower1 +
                       betMin * rew2 * 2**betPower2 +
                       betMin * rew3 * 2**betPower3 ;
        // 3. Verify proof against the withdraw contract.
        assertTrue(withdraw.verifyProof(pA,pB,pC,[uint256(root),uint256(nullifierHash),rew1,rew2,rew3,uint256(uint160(recipient)),uint256(uint160(relayer)),fee,refund]));
        // 4. Withdraw funds from the contract.
        //assertEq(recipient.balance, 0);
        //assertEq(address(lottery).balance, _amount*betMin);
        lottery.collect(pA, pB, pC, root, nullifierHash, recipient, relayer, fee, refund, rew1,rew2,rew3,0);
        if(_reward>0){
          assertGt(recipient.balance,(_reward*94)/100);
          assertEq(address(lottery).balance, 0);
        }
    }

    function _fake_play_and_get_leaf() internal returns (uint) {
        uint _amount=3;
        bytes32 commitment = bytes32(uint256(keccak256(abi.encode(i))) % FIELD_SIZE);
        lottery.play{value: _amount*betMin}(commitment,0);
        // 1.5. Process bets by admin
        (uint betsIndex, uint commitCount, uint commitBlock,uint commitHash)=lottery.getStatus();
        uint _revealSecret = uint(keccak256(commitCount));
        uint _commitHash = uint(keccak256(_revealSecret));
        lottery.commit(_commitHash);
        (uint rand,uint leaf)=lottery.reveal(_revealSecret);
        return(leaf);
    }

    function test_lottery_single_deposit() public {
        (uint _amount,bytes32 commitment,bytes32 secret,uint mask,uint rand,uint leaf) = _play_and_get_data();
        bytes32[] memory leaves = new bytes32[](1);
        leaves[0] = leaf;
        _collect(_amount,commitment,secret,mask,rand,leaves);
    }

    function test_mixer_many_deposits() public {
        bytes32[] memory leaves = new bytes32[](200);
        // 1. Make many deposits with random commitments -- this will let us test with a non-empty merkle tree
        for (uint256 i = 0; i < 100; i++) {
            leaves[i] = _fake_play_and_get_leaf();
        }
        // 2. Generate commitment and deposit.
        (uint _amount,bytes32 commitment,bytes32 secret,uint mask,uint rand,uint leaf) = _play_and_get_data();
        leaves[100] = leaf;
        // 3. Make more deposits.
        for (uint256 i = 101; i < 200; i++) {
            leaves[i] = _fake_play_and_get_leaf();
        }
        _collect(_amount,commitment,secret,mask,rand,leaves);
    }
}
