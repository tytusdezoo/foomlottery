// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {WithdrawG16Verifier} from "src/Withdraw.sol";
import {CancelBetG16Verifier} from "src/CancelBet.sol";
import {UpdateG16Verifier} from "src/Update.sol";
import {IWithdraw, ICancel, IUpdate} from "src/Lottery.sol";
import {EthLottery} from "src/EthLottery.sol";

contract EthLotteryTest is Test {
    uint public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    EthLottery public lottery;
    IWithdraw public withdraw;
    ICancel public cancel;
    IUpdate public update;

    uint blocknumber = 1;
    Vm.Log[] public allEntries;

    // Test vars
    address public constant recipient = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant relayer = address(0);
    uint public constant fee = 0;
    uint public constant refund = 0;

    uint public constant betsUpdate = 8; // TODO: compute correct value

    uint public constant betMin = 1; // TODO: compute correct value
    uint public constant betPower1 = 10; // power of the first bet = 1024
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304

    struct WithdrawData {
        uint[2] pA;
        uint[2][2] pB;
        uint[2] pC;
        uint root;
        uint nullifierHash;
        uint rew1;
        uint rew2;
        uint rew3;
    }

    struct UpdateData {
        uint[2] pA;
        uint[2][2] pB;
        uint[2] pC;
        uint oldRoot;
        uint newRoot;
        uint index;
        uint oldRand;
        uint newRand;
        uint[betsUpdate] hashes;
    }

    function setUp() public {
        // Deploy Groth16 verifier contracts.
        withdraw = IWithdraw(address(new WithdrawG16Verifier()));
        cancel = ICancel(address(new CancelBetG16Verifier()));
        update = IUpdate(address(new UpdateG16Verifier()));
        // Deploy lottery contract.
    	vm.recordLogs();
        lottery = new EthLottery(withdraw, cancel, update, IERC20(address(0)), betMin);
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

    function _fake_play(uint i) internal {
        uint hash = uint(uint240(uint(keccak256(abi.encode(i))))<<5);
        lottery.play{value: 3*betMin}(hash,0);
    }

    function _getUpdate(
        uint _oldRand,
        uint _newRand,
        uint[betsUpdate] memory _hashes,
        uint[] memory _leaves
    ) internal returns (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint oldRoot, uint newRoot, uint index, uint oldRand, uint newRand, uint[betsUpdate] memory hashes) {
        string[] memory inputs = new string[](4 + betsUpdate + _leaves.length);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/update.js";
        inputs[2] = vm.toString(bytes32(_oldRand));
        inputs[3] = vm.toString(bytes32(_newRand));
        for (uint i = 0; i < betsUpdate; i++) {
            inputs[4 + i] = vm.toString(bytes32(_hashes[i]));
        }
        for (uint i = 0; i < _leaves.length; i++) {
            inputs[4 + betsUpdate + i] = vm.toString(bytes32(_leaves[i]));
        }

        bytes memory result = vm.ffi(inputs);
        (pA, pB, pC, oldRoot, newRoot, index, oldRand, newRand, hashes) =
            abi.decode(result, (uint[2], uint[2][2], uint[2], uint, uint, uint, uint, uint, uint[8]));
        return (pA, pB, pC, oldRoot, newRoot, index, oldRand, newRand, hashes);
    }

    function _getWithdraw(
        uint _secret,
        uint _power,
        uint _rand,
        uint _index,
        address _recipient,
        address _relayer,
        uint[] memory leaves
    ) internal returns (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint root, uint nullifierHash, uint rew1, uint rew2, uint rew3) {
        string[] memory inputs = new string[](10 + leaves.length);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/withdraw.js";
        inputs[2] = vm.toString(bytes32(_secret));
        inputs[3] = vm.toString(bytes32(_power));
        inputs[4] = vm.toString(bytes32(_rand));
        inputs[5] = vm.toString(bytes32(_index));
        inputs[6] = vm.toString(_recipient);
        inputs[7] = vm.toString(_relayer);
        inputs[8] = "0";
        inputs[9] = "0";

        for (uint i = 0; i < leaves.length; i++) {
            inputs[10 + i] = vm.toString(bytes32(leaves[i]));
        }

        bytes memory result = vm.ffi(inputs);
        (pA, pB, pC, root, nullifierHash, rew1, rew2, rew3) =
            abi.decode(result, (uint[2], uint[2][2], uint[2], uint, uint, uint, uint, uint));
        return (pA, pB, pC, root, nullifierHash, rew1, rew2, rew3);
    }

    function _getUpdateData(uint _oldRand,uint _newRand,uint[betsUpdate] memory _hashes, uint[] memory _leaves) internal returns (UpdateData memory) {
        (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint oldRoot, uint newRoot, uint index, uint oldRand, uint newRand, uint[betsUpdate] memory hashes) =
            _getUpdate(_oldRand, _newRand, _hashes, _leaves);
        return UpdateData({
            pA: pA,
            pB: pB,
            pC: pC,
            oldRoot: oldRoot,
            newRoot: newRoot,
            index: index,
            oldRand: oldRand,
            newRand: newRand,
            hashes: hashes
        });
    }

    function _getWithdrawData(uint secret_power, uint rand, uint index, uint[] memory leaves) internal returns (WithdrawData memory) {
        uint secret=secret_power>>8;
        uint power=secret_power&0xFF;
        (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint root, uint nullifierHash, uint rew1, uint rew2, uint rew3) =
            _getWithdraw(secret, power, rand, index, recipient, relayer, leaves);
        return WithdrawData({
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

    function _collect(uint secret_power, uint rand, uint index, uint[] memory leaves) internal {
        WithdrawData memory data = _getWithdrawData(secret_power, rand, index, leaves);        
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

    // compute mimc(hash,rand+index)
    function _getLeaf(uint index, uint hash, uint rand) internal returns (uint leaf) {
        string[] memory inputs = new string[](5);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/getLeaf.js";
        inputs[2] = vm.toString(bytes32(index));
        inputs[3] = vm.toString(bytes32(hash));
        inputs[4] = vm.toString(bytes32(rand));
        bytes memory result = vm.ffi(inputs);
        leaf = abi.decode(result, (uint));
    }

    function _getLeaves(uint hash_power_1) internal returns (uint,uint,uint[] memory) {
        Vm.Log[] memory entries = vm.getRecordedLogs();
        uint logBetIn = uint(keccak256(abi.encodePacked("LogBetIn(uint256,uint256)")));
        uint lastrand;
        uint logBetHash = uint(keccak256(abi.encodePacked("LogBetHash(uint256,uint256,uint256)"))); // index,hash,rand
        console.log(logBetIn,"logBetIn");
        console.log(logBetHash,"logBetHash");
        console.log(entries.length,"entries.length");
        for (uint i = 0; i < entries.length; i++) {
            console.log(uint(entries[i].topics[0]));
            if (uint(entries[i].topics[0]) == logBetHash){ // add topic[4]
                uint lastindex = uint(entries[i].topics[1]);
                uint lasthash = uint(entries[i].topics[2]);
                lastrand = uint(entries[i].topics[3]);
                uint leaf = _getLeaf(lastindex,lasthash,lastrand); // very slow !!!
                //console.log(leaf,"leaf");
                bytes32[] memory newTopics = new bytes32[](5);
                for(uint j = 0; j < 4; j++) {
                    newTopics[j] = entries[i].topics[j];
                }
                newTopics[4] = bytes32(leaf);
                entries[i].topics = newTopics;
            }
            allEntries.push(entries[i]);
        }
        console.log(allEntries.length,"allEntries.length");
        uint maxLeaves = allEntries.length/2;
        uint[] memory leaves = new uint[](maxLeaves+2);
        uint leavesCount = 0;
        uint index = 0; // taken by zero
        uint rand = 0;
        lastrand = 0;
        console.log("start");
        for (uint i = 0; i < allEntries.length; i++) {
            if (uint(allEntries[i].topics[0]) == logBetHash){
                uint lastindex = uint(allEntries[i].topics[1]);
                uint lasthash = uint(allEntries[i].topics[2]);
                lastrand = uint(allEntries[i].topics[3]);
                uint leaf = uint(allEntries[i].topics[4]);
                //uint leaf = _getLeaf(lastindex,lasthash,lastrand); // very slow !!!
                console.log(leaf,"leaf");

                leaves[leavesCount++] = leaf;
                if (lasthash == hash_power_1 && hash_power_1>0) {
                    index = lastindex;
                    rand = lastrand;
                }
            }
        }
        console.log(leavesCount,"leavesCount");
        assertGt(leavesCount,0);        
        uint[] memory selectedLeaves = new uint[](leavesCount);
        for(uint i = 0; i < leavesCount; i++) {
            selectedLeaves[i] = leaves[i];
        }
        if(rand==0){
          rand=lastrand;}
        console.log(rand,"rand");
        console.log(index,"index");
        return (rand,index,selectedLeaves);
    }

    function test1_lottery_single_deposit() public {
        (uint secret_power,) = _play(10); // hash can be restored later
        console.log("%x ticket", secret_power);
        _commit_reveal();
        console.log("commited");

        (uint hash,) = _getHash(secret_power);
        (uint rand,uint index,uint[] memory leaves) = _getLeaves(hash+(secret_power&0x1f)+1);
        _collect(secret_power,rand,index,leaves);
    }

    function notest2_lottery_many_deposits() public {
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
        (uint rand,uint index,uint[] memory leaves) = _getLeaves(hash+(secret_power&0x1f)+1);
        _collect(secret_power,rand,index,leaves);
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
        lottery.rememberHash();
        console.log("after remember");
        // compute update
        (uint oldRoot,uint index,uint oldRand,uint commitBlockHash,uint[betsUpdate] memory hashes) = lottery.commited(); // could be taken from log
        console.log("after commited");
        (uint lastRand,,uint[] memory leaves) = _getLeaves(0);
        console.log("after getLeaves");
        console.log(leaves[0]);
        assertEq(index,leaves.length -1);
        assertEq(lastRand,oldRand);
        //assertEq(hashes[0],leaves[leaves.length-1]); // hashes != leaves !!!
        uint newRand = uint128(uint(keccak256(abi.encodePacked(_revealSecret,commitBlockHash))));
        UpdateData memory data = _getUpdateData(oldRand,newRand,uint[8](hashes),leaves);        
        assertEq(oldRoot,data.oldRoot);
        console.log("after getUpdateData");
        /*assertTrue(update.verifyProof(
            data.pA,
            data.pB,
            data.pC,
            [uint(data.oldRoot),uint(data.newRoot),uint(index),uint(oldRand),uint(newRand),
            uint(hashes[0]),uint(hashes[1]),uint(hashes[2]),uint(hashes[3]),uint(hashes[4]),uint(hashes[5]),uint(hashes[6]),uint(hashes[7])]
        ));*/
        assertTrue(update.verifyProof(
            data.pA,
            data.pB,
            data.pC,
            [uint(data.oldRoot),uint(data.newRoot),uint(data.index),uint(data.oldRand),uint(data.newRand),
            uint(data.hashes[0]),uint(data.hashes[1]),uint(data.hashes[2]),uint(data.hashes[3]),
            uint(data.hashes[4]),uint(data.hashes[5]),uint(data.hashes[6]),uint(data.hashes[7])]
        ));
        console.log("after assert");
        uint revealGasStart = gasleft();
        lottery.reveal(_revealSecret,data.pA,data.pB,data.pC,data.newRoot);
        uint revealGasUsed = revealGasStart - gasleft();
        console.log("Gas used in _reveal: %d", revealGasUsed);
        vm.roll(++blocknumber);
    }

}
