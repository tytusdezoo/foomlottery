// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {WithdrawG16Verifier} from "src/Withdraw.sol";
import {CancelBetG16Verifier} from "src/CancelBet.sol";
import {IWithdraw, ICancel, IHasher} from "src/Lottery.sol";
import {EthLottery} from "src/EthLottery.sol";

contract EthLotteryTest is Test {
    uint public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    EthLottery public lottery;
    IWithdraw public withdraw;
    ICancel public cancel;

    uint blocknumber = 1;
    Vm.Log[] public allEntries;

    // Test vars
    address public constant recipient = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant relayer = address(0);
    uint public constant fee = 0;
    uint public constant refund = 0;

    uint public constant betMin = 1; // TODO: compute correct value
    uint public constant betPower1 = 10; // power of the first bet = 1024
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304

    struct CollectData {
        uint[2] pA;
        uint[2][2] pB;
        uint[2] pC;
        uint root;
        uint nullifierHash;
        uint rew1;
        uint rew2;
        uint rew3;
    }

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
        lottery = new EthLottery(withdraw, cancel, IHasher(mimcHasher), IERC20(address(0)), betMin);
    	vm.recordLogs();
    }

    function _getWitnessAndProof(
        uint _secret,
        uint _power,
        uint _rand,
        address _recipient,
        address _relayer,
        bytes32[] memory leaves
    ) internal returns (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint root, uint nullifierHash, uint rew1, uint rew2, uint rew3) {
        string[] memory inputs = new string[](9 + leaves.length);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/generateWitness.js";
        inputs[2] = vm.toString(bytes32(_secret));
        inputs[3] = vm.toString(bytes32(_power));
        inputs[4] = vm.toString(bytes32(_rand));
        inputs[5] = vm.toString(_recipient);
        inputs[6] = vm.toString(_relayer);
        inputs[7] = "0";
        inputs[8] = "0";

        for (uint i = 0; i < leaves.length; i++) {
            inputs[9 + i] = vm.toString(leaves[i]);
        }

        bytes memory result = vm.ffi(inputs);
        (pA, pB, pC, root, nullifierHash, rew1, rew2, rew3) =
            abi.decode(result, (uint[2], uint[2][2], uint[2], uint, uint, uint, uint, uint));
        return (pA, pB, pC, root, nullifierHash, rew1, rew2, rew3);
    }

    function _getHash(uint _power) internal returns (uint hash, uint secret_power) {
        string[] memory inputs = new string[](3);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/getHash.js";
        inputs[2] = vm.toString(bytes32(_power));
        bytes memory result = vm.ffi(inputs);
        (hash, secret_power) = abi.decode(result, (uint, uint));
        return (hash, secret_power);
    }

    function _play(uint _power) internal returns (uint secret_power,uint hash) {
        (hash, secret_power) = _getHash(_power);
        uint gasStart = gasleft();
        lottery.play{value: betMin * (2 + 2**_power)}(hash,_power);
        uint gasUsed = gasStart - gasleft();
        console.log("Gas used in _play: %d", gasUsed);
        return (secret_power,hash);
    }

    function _get_collect_data(uint secret_power, uint rand, bytes32[] memory leaves) internal returns (CollectData memory) {
        uint secret=secret_power>>8;
        uint power=secret_power&0xFF;
        (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint root, uint nullifierHash, uint rew1, uint rew2, uint rew3) =
            _getWitnessAndProof(secret, power, rand, recipient, relayer, leaves);
        return CollectData({
            pA: pA,
            pB: pB,
            pC: pC,
            root: root,
            nullifierHash: nullifierHash,
            rew1: rew1,
            rew2: rew2,
            rew3: rew3
        });
    }

    function _collect(uint secret_power, uint rand, bytes32[] memory leaves) internal {
        CollectData memory data = _get_collect_data(secret_power, rand, leaves);        
        uint _reward = betMin * data.rew1 * 2**betPower1 +
                       betMin * data.rew2 * 2**betPower2 +
                       betMin * data.rew3 * 2**betPower3;
        console.log("%d reward",_reward);        
        assertTrue(withdraw.verifyProof(
            data.pA,
            data.pB,
            data.pC,
            [uint(data.root),uint(data.nullifierHash),data.rew1,data.rew2,data.rew3,uint(uint160(recipient)),uint(uint160(relayer)),fee,refund]
        ));
        uint gasStart = gasleft();
        lottery.collect(
            data.pA,
            data.pB,
            data.pC,
            data.root,
            data.nullifierHash,
            recipient,
            relayer,
            fee,
            refund,
            data.rew1,
            data.rew2,
            data.rew3,
            0
        );
        uint gasUsed = gasStart - gasleft();
        if(_reward>0){
            assertGt(recipient.balance,(_reward*94)/100);
        }
        console.log("Gas used in _collect: %d", gasUsed);
    }

    function _fake_play(uint i) internal /*returns (bytes32)*/ {
        uint commitment = uint(uint240(uint(keccak256(abi.encode(i))))<<5);
        lottery.play{value: 3*betMin}(commitment,0);
    }

    function _commit_reveal() internal {
        (,uint commitCount,,)=lottery.getStatus();
        uint _revealSecret = uint(keccak256(abi.encodePacked(commitCount)));
        uint _commitHash = uint(keccak256(abi.encodePacked(_revealSecret)));
        vm.roll(++blocknumber);
        uint commitGasStart = gasleft();
        lottery.commit(_commitHash);
        uint commitGasUsed = commitGasStart - gasleft();
        console.log("Gas used in _commit: %d", commitGasUsed);
        vm.roll(++blocknumber);
        uint revealGasStart = gasleft();
        lottery.reveal(_revealSecret);
        uint revealGasUsed = revealGasStart - gasleft();
        console.log("Gas used in _reveal: %d", revealGasUsed);
        vm.roll(++blocknumber);
    }

    function _get_leaves(uint hash_power_1) internal returns (uint,uint,uint,bytes32[] memory) {
        Vm.Log[] memory entries = vm.getRecordedLogs();
        // push all new entries to allEntries
        for (uint i = 0; i < entries.length; i++) {
            allEntries.push(entries[i]);
        }
        uint maxLeaves = allEntries.length/2;
        bytes32[] memory leaves = new bytes32[](maxLeaves);
        uint leavesCount = 0;
        uint index = 2**32;
        uint rand; // newhash
        uint currentLevelHash; // leaf
        uint logBetIn = uint(keccak256(abi.encodePacked("LogBetIn(uint256,uint256)")));
        uint logBetHash = uint(keccak256(abi.encodePacked("LogBetHash(uint256,uint256,uint256)")));
        for (uint i = 0; i < allEntries.length; i++) {
            if (uint(allEntries[i].topics[0]) == logBetIn){
                if (uint(allEntries[i].topics[2]) == hash_power_1) {
                    index = uint(allEntries[i].topics[1]);
                }
            }
            if (uint(allEntries[i].topics[0]) == logBetHash){
                leaves[leavesCount++] = allEntries[i].topics[3];
                if (uint(allEntries[i].topics[1]) == index) {
                    rand = uint(allEntries[i].topics[2]);
                    currentLevelHash = uint(allEntries[i].topics[3]);
                }
            }
        }
        assertGt(leavesCount,0);        
        bytes32[] memory selectedLeaves = new bytes32[](leavesCount);
        for(uint i = 0; i < leavesCount; i++) {
            selectedLeaves[i] = leaves[i];
        }
        return (index,rand,currentLevelHash,selectedLeaves);
    }

    function test1_lottery_single_deposit() public {
        (uint secret_power,) = _play(10); // hash can be restored later
        console.log("%x ticket", secret_power);
        _commit_reveal();

        (uint hash,) = _getHash(secret_power);
        (/*uint index*/,uint rand,/*uint currentLevelHash*/,bytes32[] memory leaves) = _get_leaves(hash+(secret_power&0x1f)+1);
        _collect(secret_power,rand,leaves);
    }

    function test2_lottery_many_deposits() public {
        // 1. Make many deposits with random commitments -- this will let us test with a non-empty merkle tree
        for (uint i = 0; i < 100; i++) {
            _fake_play(i);
        }
        _commit_reveal();
        // 2. Generate commitment and deposit.
        (uint secret_power,uint hash) = _play(10);
        // 3. Make more deposits.
        for (uint i = 101; i < 200; i++) {
            _fake_play(i);
        }
        _commit_reveal();
        (/*uint index*/,uint rand,/*uint currentLevelHash*/,bytes32[] memory leaves) = _get_leaves(hash+(secret_power&0x1f)+1);
        _collect(secret_power,rand,leaves);
    }
}
