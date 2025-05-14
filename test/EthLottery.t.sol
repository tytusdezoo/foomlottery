// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {WithdrawG16Verifier} from "src/Withdraw.sol";
import {CancelBetG16Verifier} from "src/CancelBet.sol";
import {Update2G16Verifier} from "src/Update2.sol";
import {Update6G16Verifier} from "src/Update6.sol";
import {Update22G16Verifier} from "src/Update22.sol";
import {IWithdraw, ICancel, IUpdate2, IUpdate6, IUpdate22} from "src/Lottery.sol";
import {EthLottery} from "src/EthLottery.sol";

contract EthLotteryTest is Test {
    uint public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    EthLottery public lottery;
    IWithdraw public withdraw;
    ICancel public cancel;
    IUpdate2 public update2;
    IUpdate6 public update6;
    IUpdate22 public update22;


    uint blocknumber = 1;
    Vm.Log[] public allEntries;

    // Test vars
    address public constant recipient = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant relayer = address(0);
    uint public constant fee = 0;
    uint public constant refund = 0;

    uint public constant maxUpdate = 22; // TODO: compute correct value

    uint public constant betMin = 1; // TODO: compute correct value
    uint public constant betPower1 = 10; // power of the first bet = 1024
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304

    uint logBetIn = uint(keccak256(abi.encodePacked("LogBetIn(uint256,uint256)")));
    uint logBetHash = uint(keccak256(abi.encodePacked("LogBetHash(uint256,uint256,uint256)"))); // index,hash,rand

    struct WithdrawData {
        uint[2] pA;
        uint[2][2] pB;
        uint[2] pC;
        uint root;
        uint nullifierHash;
        uint rewardbits;
    }

    struct CancelBetData {
        uint[2] pA;
        uint[2][2] pB;
        uint[2] pC;
        uint hash;
        uint secret;
    }

    struct UpdateData {
        uint[2] pA;
        uint[2][2] pB;
        uint[2] pC;
        uint oldRoot;
        uint newRoot;
        uint index;
        uint newRand;
        //uint[maxUpdate] hashes;
        uint[] hashes;
    }

    function setUp() public {
        // Deploy Groth16 verifier contracts.
        withdraw = IWithdraw(address(new WithdrawG16Verifier()));
        cancel = ICancel(address(new CancelBetG16Verifier()));
        update2 = IUpdate2(address(new Update2G16Verifier()));
        update6 = IUpdate6(address(new Update6G16Verifier()));
        update22 = IUpdate22(address(new Update22G16Verifier()));
        // Deploy lottery contract.
    	vm.recordLogs();
        lottery = new EthLottery(withdraw, cancel, update2, update6, update22, IERC20(address(0)), betMin);
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
        uint _commitIndex,
        uint _oldRand,
        uint _newRand,
        uint[maxUpdate] memory _hashes,
        uint[] memory _leaves
    ) internal returns (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint oldRoot, uint newRoot, uint index, uint newRand, uint[] memory hashes) {
        string[] memory inputs = new string[](5 + maxUpdate + _leaves.length);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/update.js";
        inputs[2] = vm.toString(bytes32(_commitIndex));
        inputs[3] = vm.toString(bytes32(_oldRand));
        inputs[4] = vm.toString(bytes32(_newRand));
        for (uint i = 0; i < maxUpdate; i++) {
            inputs[5 + i] = vm.toString(bytes32(_hashes[i]));
        }
        for (uint i = 0; i < _leaves.length; i++) {
            inputs[5 + maxUpdate + i] = vm.toString(bytes32(_leaves[i]));
        }

	//console.log("before update");
        bytes memory result = vm.ffi(inputs);
	//console.log("after update");
        (pA, pB, pC, oldRoot, newRoot, index, newRand, hashes) =
            abi.decode(result, (uint[2], uint[2][2], uint[2], uint, uint, uint, uint, 
            uint[] // maxUpdate
            ));
	//console.log("after parse");
        return (pA, pB, pC, oldRoot, newRoot, index, newRand, hashes);
    }

    function _getWithdraw(
        uint _secret,
        uint _power,
        uint _rand,
        uint _index,
        address _recipient,
        address _relayer,
        uint[] memory leaves
    ) internal returns (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint root, uint nullifierHash, uint rewardbits) {
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
        (pA, pB, pC, root, nullifierHash, rewardbits) =
            abi.decode(result, (uint[2], uint[2][2], uint[2], uint, uint, uint));
        return (pA, pB, pC, root, nullifierHash, rewardbits);
    }

    function _getUpdateData(uint _commitIndex,uint _oldRand,uint _newRand,uint[maxUpdate] memory _hashes, uint[] memory _leaves) internal returns (UpdateData memory) {
        (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint oldRoot, uint newRoot, uint index, uint newRand, uint[] memory hashes) =
            _getUpdate(_commitIndex,_oldRand, _newRand, _hashes, _leaves);
        return UpdateData({
            pA: pA,
            pB: pB,
            pC: pC,
            oldRoot: oldRoot,
            newRoot: newRoot,
            index: index,
            newRand: newRand,
            hashes: hashes
        });
    }

    function _getWithdrawData(uint secret_power, uint rand, uint index, uint[] memory leaves) internal returns (WithdrawData memory) {
        uint secret=secret_power>>8;
        uint power=secret_power&0xFF;
        (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint root, uint nullifierHash, uint rewardbits) =
            _getWithdraw(secret, power, rand, index, recipient, relayer, leaves);
        return WithdrawData({
            pA: pA,
            pB: pB,
            pC: pC,
            root: root,
            nullifierHash: nullifierHash,
            rewardbits: rewardbits
        });
    }

    function _withdraw(uint secret_power, uint rand, uint index, uint[] memory leaves) internal {
        WithdrawData memory data = _getWithdrawData(secret_power, rand, index, leaves);        
        uint reward =  betMin * ( (data.rewardbits&0x1>0?1:0) * 2**betPower1 + (data.rewardbits&0x2>0?1:0) * 2**betPower2 + (data.rewardbits&0x4>0?1:0) * 2**betPower3 );
        console.log("%d reward",reward);        
        uint gasStart = gasleft();
        assertTrue(withdraw.verifyProof(
            data.pA,
            data.pB,
            data.pC,
            [uint(data.root),uint(data.nullifierHash),data.rewardbits,uint(uint160(recipient)),uint(uint160(relayer)),fee,refund]
        ));
        uint gasUsed = gasStart - gasleft();
        console.log("Gas used in withdraw.verifyProof: %d", gasUsed); // 251799
        gasStart = gasleft();
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
            data.rewardbits,
            0
        );
        gasUsed = gasStart - gasleft();
        if(reward>0){
            assertGt(recipient.balance,(reward*94)/100);
        }
        console.log("Gas used in _withdraw: %d", gasUsed);
    }

    function _getCancelBet(
        uint _secret_power,
        uint _hash
    ) internal returns (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint hash, uint secret) {
        string[] memory inputs = new string[](4);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/cancelBet.js";
        inputs[2] = vm.toString(bytes32(_secret_power));
        inputs[3] = vm.toString(bytes32(_hash));
        bytes memory result = vm.ffi(inputs);
        (pA, pB, pC, hash, secret) =
            abi.decode(result, (uint[2], uint[2][2], uint[2], uint, uint));
        return (pA, pB, pC, hash, secret);
    }

    function _getCancelBetData(uint _secret_power, uint _hash) internal returns (CancelBetData memory) {
        (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint hash, uint secret) =
            _getCancelBet(_secret_power, _hash);
        return CancelBetData({ pA: pA, pB: pB, pC: pC, hash: hash, secret: secret });
    }

    function _cancelbet(uint secret_power, uint hash, uint index) internal {
        CancelBetData memory data = _getCancelBetData(secret_power, hash);        
        uint gasStart = gasleft();
        assertTrue(cancel.verifyProof(data.pA,data.pB,data.pC,[uint(data.hash)]));
        uint gasUsed = gasStart - gasleft();
        console.log("Gas used in cancel.verifyProof: %d", gasUsed); // 199867 [1 parameter] , 228591 [5 parameters]
        gasStart = gasleft();
        console.log(index,"cancel index");
        //console.log(hash,"hash");
        lottery.cancelbet(data.pA,data.pB,data.pC,index,recipient);
        gasUsed = gasStart - gasleft();
        console.log("Gas used in _cancelbet: %d", gasUsed);
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

    function _getLogs() internal {
        Vm.Log[] memory entries = vm.getRecordedLogs();
        //console.log(logBetIn,"logBetIn");
        //console.log(logBetHash,"logBetHash");
        //console.log(entries.length,"entries.length");
        for (uint i = 0; i < entries.length; i++) {
            //console.log(uint(entries[i].topics[0]));
            if (uint(entries[i].topics[0]) == logBetHash){ // add topic[4]
                uint lastindex = uint(entries[i].topics[1]);
                uint lasthash = uint(entries[i].topics[2]);
                uint lastrand = uint(entries[i].topics[3]);
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
    }

    function _getIndex(uint hash_power_1) internal returns (uint) {
        _getLogs();
        for (uint i = 0; i < allEntries.length; i++) {
            if (uint(allEntries[i].topics[0]) == logBetIn){
                uint lastindex = uint(allEntries[i].topics[1]);
                uint lasthash = uint(allEntries[i].topics[2]);
                if (lasthash == hash_power_1) {
                    return(lastindex);
                }
            }
        }
        return(0);
    }


    function _getLeaves(uint hash_power_1) internal returns (uint,uint,uint[] memory) {
        _getLogs();
        uint maxLeaves = allEntries.length/2;
        uint[] memory leaves = new uint[](maxLeaves+2);
        uint leavesCount = 0;
        uint index = 0; // taken by zero
        uint rand = 0;
        uint lastrand = 0;
        for (uint i = 0; i < allEntries.length; i++) {
            if (uint(allEntries[i].topics[0]) == logBetHash){
                uint lastindex = uint(allEntries[i].topics[1]);
                uint lasthash = uint(allEntries[i].topics[2]);
                lastrand = uint(allEntries[i].topics[3]);
                uint leaf = uint(allEntries[i].topics[4]);
                leaves[leavesCount++] = leaf;
                if (lasthash == hash_power_1 && hash_power_1>0) {
                    index = lastindex;
                    rand = lastrand;
                }
            }
        }
        assertGt(leavesCount,0);        
        uint[] memory selectedLeaves = new uint[](leavesCount);
        for(uint i = 0; i < leavesCount; i++) {
            selectedLeaves[i] = leaves[i];
        }
        if(rand==0){
          rand=lastrand;}
        return (rand,index,selectedLeaves);
    }

    function test1_lottery_cancel() public {
        vm.roll(++blocknumber);
        (uint secret_power,) = _play(10); // hash can be restored later
        console.log("%x ticket", secret_power);
        _commit_reveal();
        (uint secret_power2,uint hash2) = _play(4); // hash can be restored later
        (uint index2) = _getIndex(hash2+(secret_power2&0x1f)+1);
        _cancelbet(secret_power2,hash2,index2);
    }

    function notest2_lottery_single_deposit() public {
        vm.roll(++blocknumber);
        (uint secret_power,) = _play(10); // hash can be restored later
        console.log("%x ticket", secret_power);
        _commit_reveal();
        (uint hash,) = _getHash(secret_power);
        (uint rand,uint index,uint[] memory leaves) = _getLeaves(hash+(secret_power&0x1f)+1);
        _withdraw(secret_power,rand,index,leaves);
    }

    function test3_lottery_many_deposits() public {
        uint i;
        uint secret_power;
        uint hash;
        uint rand;
        uint index;
        uint[] memory leaves;
        vm.roll(++blocknumber);
        for (i = 0; i < 1*maxUpdate+10; i++) {
            _fake_play(i);}
        vm.roll(++blocknumber);
        _commit_reveal();
        _commit_reveal();
        for (; i < 2*maxUpdate+10; i++) {
            _fake_play(i);}
        _commit_reveal();
        (secret_power,hash) = _play(10);
        for (; i < 3*maxUpdate+10; i++) {
            _fake_play(i);}
        _commit_reveal();
        _commit_reveal();
        (rand,index,leaves) = _getLeaves(hash+(secret_power&0x1f)+1);
        _withdraw(secret_power,rand,index,leaves);
        (secret_power,hash) = _play(2);
        for (; i < 4*maxUpdate+10; i++) {
            _fake_play(i);}
        _commit_reveal();
        _commit_reveal();
        (rand,index,leaves) = _getLeaves(hash+(secret_power&0x1f)+1);
        _withdraw(secret_power,rand,index,leaves);
    }

    function _commit_reveal() internal {
        (uint nextIndex,,,)=lottery.getStatus();
        uint _revealSecret = uint(keccak256(abi.encodePacked(nextIndex)));
        uint _commitHash = uint(keccak256(abi.encodePacked(_revealSecret)));
        vm.roll(++blocknumber);
        uint commitGasStart = gasleft();
        lottery.commit(_commitHash);
        uint commitGasUsed = commitGasStart - gasleft();
        console.log("Gas used in _commit: %d", commitGasUsed);
        vm.roll(++blocknumber);
        lottery.rememberHash();
        //console.log("after remember");
        // compute update
        (uint oldRoot,uint index,uint oldRand,uint commitBlock, uint commitBlockHash,uint commitIndex,uint[maxUpdate] memory hashes) = lottery.commited(); // could be taken from log
        if(commitBlock==0){
          console.log("no tickets");
          return;}
        //console.log(oldRoot,"oldRoot");
        //console.log("after commited");
        (uint lastRand,,uint[] memory leaves) = _getLeaves(0);
        //console.log("after getLeaves");
        //console.log(leaves[0]);
        assertEq(index,leaves.length -1);
        //console.log("index ok");
        assertEq(lastRand,oldRand);
        //console.log("lastRand ok");
        //assertEq(hashes[0],leaves[leaves.length-1]); // hashes != leaves !!!
        uint newRand = uint128(uint(keccak256(abi.encodePacked(_revealSecret,commitBlockHash))));
        //UpdateData memory data = _getUpdateData(oldRand,newRand,uint[maxUpdate](hashes),leaves);        
        //console.log("update start");
        UpdateData memory data = _getUpdateData(commitIndex,oldRand,newRand,hashes,leaves);        
        //console.log("update ok");
        //console.log(data.oldRoot,"data.oldRoot");
        assertEq(oldRoot,data.oldRoot);
        //console.log("after getUpdateData");
        //console.log("assert update");
        if(commitIndex<=2){
          uint[4+2] memory pubdata;
          pubdata[0]=data.oldRoot;
          pubdata[1]=data.newRoot;
          pubdata[2]=data.index;
          pubdata[3]=data.newRand;
          for(uint i=0;i<2;i++){
              pubdata[4+i]=data.hashes[i];}
          uint revealGasStart = gasleft();
          assertTrue(update2.verifyProof( data.pA, data.pB, data.pC, pubdata));
          uint revealGasUsed = revealGasStart - gasleft();
          console.log("Gas used in update2.verifyProof: %d", revealGasUsed);
          //console.log("after assert");
          revealGasStart = gasleft();
          lottery.reveal(_revealSecret,data.pA,data.pB,data.pC,data.newRoot,2);
          revealGasUsed = revealGasStart - gasleft();
          console.log("Gas used in _reveal2: %d", revealGasUsed);}
        else if(commitIndex<=6){
          uint[4+6] memory pubdata;
          pubdata[0]=data.oldRoot;
          pubdata[1]=data.newRoot;
          pubdata[2]=data.index;
          pubdata[3]=data.newRand;
          for(uint i=0;i<6;i++){
              pubdata[4+i]=data.hashes[i];}
          uint revealGasStart = gasleft();
          assertTrue(update6.verifyProof( data.pA, data.pB, data.pC, pubdata));
          uint revealGasUsed = revealGasStart - gasleft();
          console.log("Gas used in update6.verifyProof: %d", revealGasUsed);
          //console.log("after assert");
          revealGasStart = gasleft();
          lottery.reveal(_revealSecret,data.pA,data.pB,data.pC,data.newRoot,6);
          revealGasUsed = revealGasStart - gasleft();
          console.log("Gas used in _reveal6: %d", revealGasUsed);}
        else{
          uint[4+22] memory pubdata;
          pubdata[0]=data.oldRoot;
          pubdata[1]=data.newRoot;
          pubdata[2]=data.index;
          pubdata[3]=data.newRand;
          for(uint i=0;i<22;i++){
              pubdata[4+i]=data.hashes[i];}
          uint revealGasStart = gasleft();
          assertTrue(update22.verifyProof( data.pA, data.pB, data.pC, pubdata));
          uint revealGasUsed = revealGasStart - gasleft();
          console.log("Gas used in update22.verifyProof: %d", revealGasUsed);
          //console.log("after assert");
          revealGasStart = gasleft();
          lottery.reveal(_revealSecret,data.pA,data.pB,data.pC,data.newRoot,22);
          revealGasUsed = revealGasStart - gasleft();
          console.log("Gas used in _reveal22: %d", revealGasUsed);}
        vm.roll(++blocknumber);
    }

}
