// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {WithdrawG16Verifier} from "src/Withdraw.sol";
import {CancelBetG16Verifier} from "src/CancelBet.sol";
import {Update1G16Verifier} from "src/Update1.sol";
import {Update5G16Verifier} from "src/Update5.sol";
import {Update21G16Verifier} from "src/Update21.sol";
import {Update44G16Verifier} from "src/Update44.sol";
import {IWithdraw, ICancel, IUpdate1, IUpdate5, IUpdate21, IUpdate44} from "src/Lottery.sol";
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
    uint oldIndex = 0;
    uint commitIndex=0;
    Vm.Log[] public allLeaves;

    // Test vars
    address public constant recipient = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant relayer = address(0);
    uint public constant fee = 0;
    uint public constant refund = 0;

    uint public constant betMin = 0.001 ether; // TODO: compute correct value
    uint public constant betPower1 = 10; // power of the first bet = 1024
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304

    //uint logBetHash = uint(keccak256(abi.encodePacked("LogBetHash(uint256,uint256,uint256)"))); // index,hash,rand
    uint logBetIn = uint(keccak256(abi.encodePacked("LogBetIn(uint256,uint256)"))); // index,newHash
    uint logCancel = uint(keccak256(abi.encodePacked("LogCancel(uint256)"))); // index
    uint logUpdate = uint(keccak256(abi.encodePacked("LogUpdate(uint256,uint256,uint256)"))); // index,newRand,newRoot
    uint logCommit = uint(keccak256(abi.encodePacked("LogCommit(uint256,uint256,uint256)"))); // index,newRand,newRoot

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

    function _getLogs() internal {
        Vm.Log[] memory entries = vm.getRecordedLogs();
        for (uint i = 0; i < entries.length; i++) {
            if (uint(entries[i].topics[0]) == LogCancel){
                uint index = uint(entries[i].topics[1]);
                allLeaves[index].topics[2]=0x20;}
            if (uint(entries[i].topics[0]) == LogBetIn){
                assertEq(allLeaves.length == entries[i].topic[1]);
                if(oldIndex==0){
                    assertEq(entries[i].topics[2],0x0ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae520);
                    entries[i].topics[0]=0; // rand
                    entries[i].topics[1]=0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0; // leaf
                    oldIndex=1;}
                allLeaves.push(entries[i]);}
            if (uint(entries[i].topics[0]) == LogUpdate){
                uint newIndex = uint(entries[i].topics[1]);
                uint newRand = uint(entries[i].topics[2]);
                uint hashesLength = newIndex-oldIndex;
                string[] memory inputs = new string[](4+hashes.length);
                inputs[0] = "node";
                inputs[1] = "forge-ffi-scripts/getLeaves.js";
                inputs[2] = vm.toString(bytes32(oldIndex));
                inputs[3] = vm.toString(bytes32(newRand));
                for (uint i = 0; i < hashes.length; i++) {
                    inputs[4+i] = vm.toString(bytes32(allLeaves[oldIndex+i].topics[2]));}
                bytes memory result = vm.ffi(inputs);
                (uint[] memory leaves) = abi.decode(result, (uint[]));
                for(uint i=0;i<hashesLength;i++){
                    allLeaves[oldIndex+i].topics[0]=newRand;
                    allLeaves[oldIndex+i].topics[1]=leaves[i];} // overwrite topic 1 (index)
                oldIndex=newIndex;}
            if (uint(entries[i].topics[0]) == LogCommit){
                assertEq(allLeaves.length == entries[i].topic[1]);
                commitIndex=entries[i].topic[2]);}}
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

    function _cancelbet(uint secret_power, uint hash, uint index) internal {
        string[] memory inputs = new string[](4);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/cancelBet.js";
        inputs[2] = vm.toString(bytes32(secret_power));
        inputs[3] = vm.toString(bytes32(hash));
        bytes memory result = vm.ffi(inputs);
        (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC,uint[1] data) = abi.decode(result, (uint[2], uint[2][2], uint[2], uint[1]));
        uint gasStart = gasleft();
        assertTrue(cancel.verifyProof(pA,pB,pC,data));
        uint gasUsed = gasStart - gasleft();
        console.log("Gas used in cancel.verifyProof: %d", gasUsed);
        gasStart = gasleft();
        console.log(index,"cancel index");
        lottery.cancelbet(pA,pB,pC,index,recipient);
        gasUsed = gasStart - gasleft();
        console.log("Gas used in _cancelbet: %d", gasUsed);
    }

    function _withdraw(uint secret_power, uint rand, uint index) internal {
        string[] memory inputs = new string[](10 + oldIndex);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/withdraw.js";
        inputs[2] = vm.toString(bytes32(_secret_power>>8));
        inputs[3] = vm.toString(bytes32(_secret_power&0xFF));
        inputs[4] = vm.toString(bytes32(_rand));
        inputs[5] = vm.toString(bytes32(_index));
        inputs[6] = vm.toString(recipient);
        inputs[7] = vm.toString(relayer);
        inputs[8] = "0";
        inputs[9] = "0";
        for (uint i = 0; i < leaves.length; i++) {
            inputs[10 + i] = vm.toString(bytes32(allLeaves[i].topics[1]));}
        bytes memory result = vm.ffi(inputs);
        (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint[3] memory data) =
            abi.decode(result, (uint[2], uint[2][2], uint[2], uint[3]));
        uint root=data[0];
        uint nullifierHash=data[1];
        uint rewardbits=data[2];
        uint reward =  betMin * ( (rewardbits&0x1>0?1:0) * 2**betPower1 + (rewardbits&0x2>0?1:0) * 2**betPower2 + (rewardbits&0x4>0?1:0) * 2**betPower3 );
        console.log("%d reward",reward);        
        uint gasStart = gasleft();
        assertTrue(withdraw.verifyProof(pA,pB,pC,data));
        uint gasUsed = gasStart - gasleft();
        console.log("Gas used in withdraw.verifyProof: %d", gasUsed);
        gasStart = gasleft();
        lottery.collect( pA, pB, pC, root, nullifierHash, recipient, relayer, 0, 0, rewardbits, 0);
        gasUsed = gasStart - gasleft();
        if(reward>0){
            assertGt(recipient.balance,(reward*94)/100);}
        console.log("Gas used in _withdraw: %d", gasUsed);
    }

    function updateSize(uint commitSize) pure public returns (uint) {
        if(commitSize<=1){
          return(1);}
        if(commitSize<=5){
          return(5);}
        if(commitSize<=21){
          return(21);}
        return(44);
    }

    function _commit_reveal() internal {
        _getLogs():
        if(commitIndex==0){
          console.log("no tickets");
          return;}
        vm.roll(++blocknumber);
        uint _revealSecret = uint(keccak256(abi.encodePacked(nextIndex)));
        uint _commitHash = uint(keccak256(abi.encodePacked(_revealSecret)));
        uint commitGasStart = gasleft();
        lottery.commit(_commitHash);
        uint commitGasUsed = commitGasStart - gasleft();
        console.log("Gas used in _commit: %d", commitGasUsed);
        vm.roll(++blocknumber);
        lottery.rememberHash();
        console.log("after remember");
        // compute update
        uint newRand = uint128(uint(keccak256(abi.encodePacked(_revealSecret,commitBlockHash))));
        uint hashesLength = updateSize(commitIndex);
        string[] memory inputs = new string[](4 + hashesLength + oldIndex);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/update.js";
        inputs[2] = vm.toString(bytes32(hashesLength));
        inputs[3] = vm.toString(bytes32(newRand));
        for (uint i = 0; i < hashesLength; i++){
            if(i<commitIndex){
                inputs[4 + i] = vm.toString(bytes32(allLeaves[oldIndex+i].topics[2]));}
            else{
                inputs[4 + i] = vm.toString(bytes32(0));}}
        for (uint i = 0; i < oldIndex; i++){
            inputs[4 + hashesLength + i] = vm.toString(bytes32(allLeaves[i].topics[1]));}
        //console.log("before update");
        bytes memory result = vm.ffi(inputs);
        //console.log("after update");
        (uint[2] memory pA,uint[2][2] memory pB,uint[2] memory pC,uint[] memory data)=abi.decode(result,(uint[2],uint[2][2],uint[2],uint[]));
        //console.log("after getUpdateData");
        //console.log("assert update");
        uint revealGasStart;
        if(hashesLength==1){
          uint[1] pubdata;for(uint i=0;i<1;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update2.verifyProof(pA,pB,pC,pubdata));}
        else if(hashesLength==5){
          uint[5] pubdata;for(uint i=0;i<5;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update6.verifyProof(pA,pB,pC,pubdata));}
        else if(hashesLength==21){
          uint[21] pubdata;for(uint i=0;i<21;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update22.verifyProof(pA,pB,pC,pubdata));}
        else{
          uint[44] pubdata;for(uint i=0;i<44;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update45.verifyProof(pA,pB,pC,pubdata));}
        uint revealGasUsed = revealGasStart - gasleft();
        console.log("Gas used in update[",hashesLength,"].verifyProof: %d", revealGasUsed);
        revealGasStart = gasleft();
        lottery.reveal(_revealSecret,pA,pB,pC,data[1]); // data[1]=newRoot
        revealGasUsed = revealGasStart - gasleft();
        console.log("Gas used in _reveal[",hashesLength,"]: %d", revealGasUsed);
        vm.roll(++blocknumber);
        commitIndex=0;
    }

    function _getRandIndex(uint hash_power_1) internal returns (uint,uint) {
        _getLogs();
        for (uint i = 0; i < allLeaves.length; i++){
            if (allLeaves[i].topics[2] == hash_power_1){
                return(allLeaves[i].topics[0],i);}}
        return(0,0);
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

    function test1_lottery_cancel() public {
        vm.roll(++blocknumber);
        (uint secret_power,) = _play(10); // hash can be restored later
        console.log("%x ticket", secret_power);
        _commit_reveal();
        (uint secret_power2,uint hash2) = _play(4); // hash can be restored later
        (uint rand2,uint index2) = _getRandIndex(hash2+(secret_power2&0x1f)+1);
        _cancelbet(secret_power2,hash2,index2);
    }

    function notest2_lottery_single_deposit() public {
        vm.roll(++blocknumber);
        (uint secret_power,) = _play(10); // hash can be restored later
        console.log("%x ticket", secret_power);
        _commit_reveal();
        (uint hash,) = _getHash(secret_power);
        (uint rand,uint index) = _getRandIndex(hash+(secret_power&0x1f)+1);
        _withdraw(secret_power,rand,index);
    }

    function notest3_lottery_many_deposits() public {
        uint i;
        uint secret_power;
        uint hash;
        uint rand;
        uint index;
        vm.roll(++blocknumber);
        for (i = 0; i < 10; i++) {
            _fake_play(i);}
        vm.roll(++blocknumber);
        _commit_reveal();
        _commit_reveal();
        for (; i < 20; i++) {
            _fake_play(i);}
        _commit_reveal();
        (secret_power,hash) = _play(10);
        for (; i < 60; i++) {
            _fake_play(i);}
        _commit_reveal();
        _commit_reveal();
        (rand,index) = _getRandIndex(hash+(secret_power&0x1f)+1);
        _withdraw(secret_power,rand,index);
        (secret_power,hash) = _play(2);
        for (; i < 130; i++) {
            _fake_play(i);}
        _commit_reveal();
        _commit_reveal();
        (rand,index) = _getRandIndex(hash+(secret_power&0x1f)+1);
        _withdraw(secret_power,rand,index);
    }
}
