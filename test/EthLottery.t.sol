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
    IUpdate1 public update1;
    IUpdate5 public update5;
    IUpdate21 public update21;
    IUpdate44 public update44;

    uint blocknumber = 1;
    uint oldIndex = 0;
    uint commitIndex=0;
    Vm.Log[] public allLeaves;

    // Test vars
    address public constant relayer = address(0);
    address public recipient = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint public fee = 0;
    uint public refund = 0;
    uint public invest = 0;

    uint public constant betMin = 1; //0.001 ether; // TODO: compute correct value
    uint public constant betPower1 = 10; // power of the first bet = 1024
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304

    //uint logBetHash = uint(keccak256(abi.encodePacked("LogBetHash(uint256,uint256,uint256)"))); // index,hash,rand
    uint LogBetIn = uint(keccak256(abi.encodePacked("LogBetIn(uint256,uint256)"))); // index,newHash
    uint LogCancel = uint(keccak256(abi.encodePacked("LogCancel(uint256)"))); // index
    uint LogUpdate = uint(keccak256(abi.encodePacked("LogUpdate(uint256,uint256,uint256)"))); // index,newRand,newRoot
    uint LogCommit = uint(keccak256(abi.encodePacked("LogCommit(uint256,uint256,uint256)"))); // index,newRand,newRoot

    function setUp() public {
        // Deploy Groth16 verifier contracts.
        withdraw = IWithdraw(address(new WithdrawG16Verifier()));
        cancel = ICancel(address(new CancelBetG16Verifier()));
        update1 = IUpdate1(address(new Update1G16Verifier()));
        update5 = IUpdate5(address(new Update5G16Verifier()));
        update21 = IUpdate21(address(new Update21G16Verifier()));
        update44 = IUpdate44(address(new Update44G16Verifier()));
        // Deploy lottery contract.
        vm.roll(++blocknumber);
    	vm.recordLogs();
        lottery = new EthLottery(withdraw, cancel, update1, update5, update21, update44, IERC20(address(0)), betMin);
    }

    function _getLogs() internal {
        Vm.Log[] memory entries = vm.getRecordedLogs();
        for (uint i = 0; i < entries.length; i++) {
            if (uint(entries[i].topics[0]) == LogCancel){
                uint index = uint(entries[i].topics[1]);
                allLeaves[index].topics[2]=bytes32(uint(0x20));}
            if (uint(entries[i].topics[0]) == LogBetIn){
                assertEq(uint(allLeaves.length),uint(entries[i].topics[1]),"lost bet?");
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
                string[] memory inputs = new string[](4+hashesLength);
                inputs[0] = "node";
                inputs[1] = "forge-ffi-scripts/getLeaves.js";
                inputs[2] = vm.toString(bytes32(oldIndex));
                inputs[3] = vm.toString(bytes32(newRand));
                for (uint j = 0; j < hashesLength; j++) {
                    inputs[4+j] = vm.toString(bytes32(allLeaves[oldIndex+j].topics[2]));}
                bytes memory result = vm.ffi(inputs);
                (uint[] memory leaves) = abi.decode(result, (uint[]));
                for(uint j=0;j<hashesLength;j++){
                    allLeaves[oldIndex+j].topics[0]=bytes32(newRand);
                    allLeaves[oldIndex+j].topics[1]=bytes32(leaves[j]);} // overwrite topic 1 (index)
                oldIndex=newIndex;}
            if (uint(entries[i].topics[0]) == LogCommit){
                assertEq(uint(oldIndex),uint(entries[i].topics[1]),"missed index update?");
                commitIndex=uint(entries[i].topics[2]);}}
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
        (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC,uint[1] memory data) = abi.decode(result, (uint[2], uint[2][2], uint[2], uint[1]));
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
        inputs[2] = vm.toString(bytes32(secret_power>>8));
        inputs[3] = vm.toString(bytes32(secret_power&0xFF));
        inputs[4] = vm.toString(bytes32(rand));
        inputs[5] = vm.toString(bytes32(index));
        inputs[6] = vm.toString(recipient);
        inputs[7] = vm.toString(relayer);
        inputs[8] = "0x0";
        inputs[9] = "0x0";
        for (uint i = 0; i < oldIndex; i++) {
            inputs[10 + i] = vm.toString(bytes32(allLeaves[i].topics[1]));}
        bytes memory result = vm.ffi(inputs);
        (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC, uint[7] memory data) =
            abi.decode(result, (uint[2], uint[2][2], uint[2], uint[7]));
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
        lottery.collect( pA, pB, pC, root, nullifierHash, recipient, relayer, 0, 0, rewardbits, invest);
        gasUsed = gasStart - gasleft();
        if(reward>0){
            //assertGt(recipient.balance,(reward*94)/100);
            console.log("Balance: %d\n",recipient.balance);}
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
        _getLogs();
        if(allLeaves.length==oldIndex){
          console.log("no tickets");
          return;}
        vm.roll(++blocknumber);
        uint _revealSecret = uint(keccak256(abi.encodePacked(oldIndex)));
        uint _commitHash = uint(keccak256(abi.encodePacked(_revealSecret)));
        uint commitGasStart = gasleft();
        lottery.commit(_commitHash);
        uint commitGasUsed = commitGasStart - gasleft();
        console.log("Gas used in _commit: %d", commitGasUsed);
        vm.roll(++blocknumber);
        lottery.rememberHash();
        //console.log("after remember");
        _getLogs();
        // compute update
        uint newRand = uint128(uint(keccak256(abi.encodePacked(_revealSecret,lottery.commitBlockHash())))); // reads lottery.commitBlockHash ... could read from Logs later !!!
        uint hashesLength = updateSize(commitIndex);
        string[] memory inputs = new string[](4 + hashesLength + oldIndex);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/update.js";
        inputs[2] = vm.toString(hashesLength);
        inputs[3] = vm.toString(bytes32(newRand));
        //console.log(commitIndex,"commmitIndex");
        for (uint i = 0; i < hashesLength; i++){
            if(i<commitIndex){
                //console.log("leaf %x",uint(bytes32(allLeaves[oldIndex+i].topics[2])));
                inputs[4 + i] = vm.toString(bytes32(allLeaves[oldIndex+i].topics[2]));}
            else{
                inputs[4 + i] = vm.toString(bytes32(0));}}
        for (uint i = 0; i < oldIndex; i++){
            inputs[4 + hashesLength + i] = vm.toString(bytes32(allLeaves[i].topics[1]));}
        //console.log("before update");
        bytes memory result = vm.ffi(inputs);
        //console.log("after update");
        (uint[2] memory pA,uint[2][2] memory pB,uint[2] memory pC,uint[] memory data)=abi.decode(result,(uint[2],uint[2][2],uint[2],uint[]));
        //console.log("after decode");
        uint revealGasStart;
        if(hashesLength==1){
          uint[4+1] memory pubdata;for(uint i=0;i<4+1;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update1.verifyProof(pA,pB,pC,pubdata));}
        else if(hashesLength==5){
          uint[4+5] memory pubdata;for(uint i=0;i<4+5;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update5.verifyProof(pA,pB,pC,pubdata));}
        else if(hashesLength==21){
          uint[4+21] memory pubdata;for(uint i=0;i<4+21;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update21.verifyProof(pA,pB,pC,pubdata));}
        else{
          uint[4+44] memory pubdata;for(uint i=0;i<4+44;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update44.verifyProof(pA,pB,pC,pubdata));}
        //console.log("after assert");
        uint revealGasUsed = revealGasStart - gasleft();
        console.log("Gas used in update[%d].verifyProof: %d", hashesLength,revealGasUsed);
        revealGasStart = gasleft();
        lottery.reveal(_revealSecret,pA,pB,pC,data[1]); // data[1]=newRoot
        revealGasUsed = revealGasStart - gasleft();
        console.log("Gas used in _reveal[%d]: %d", hashesLength,revealGasUsed);
        vm.roll(++blocknumber);
        commitIndex=0;
    }

    function _getRandIndex(uint hash_power_1) internal returns (uint,uint) {
        _getLogs();
        for (uint i = 0; i < allLeaves.length; i++){
            if (uint(allLeaves[i].topics[2]) == hash_power_1){
                return(uint(allLeaves[i].topics[0]),i);}}
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

    function view_status() view public {
        address me=payable(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
        uint balance=me.balance;
        uint ballot=address(lottery).balance;
        uint wallet=lottery.walletBalanceOf(me);
        uint shares=lottery.walletSharesOf(me);
        console.log("ballot : %d",ballot);
        console.log("balance: %d",balance);
        console.log("wallet : %d",wallet);
        console.log("shares : %d",shares);
    }

    function notest0_investments() public {
        view_status();
        uint secret_power;
        uint hash;
        uint rand;
        uint index;
        uint periodBlocks=lottery.periodBlocks();
        console.log("period %d",periodBlocks);
        console.log("me %x",msg.sender); // 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
        vm.roll(++blocknumber);
        (secret_power,hash) = _play(10);
        _commit_reveal();
        (rand,index) = _getRandIndex(hash+(secret_power&0x1f)+1);
        invest = 500;
        recipient = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        _withdraw(secret_power,rand,index);
        view_status();
    }

    function notest1_lottery_cancel() public {
        vm.roll(++blocknumber);
        _fake_play(0);
        (uint secret_power,) = _play(10); // hash can be restored later
        console.log("%x ticket", secret_power);
        _commit_reveal();
        (uint secret_power2,uint hash2) = _play(4); // hash can be restored later
        (,uint index2) = _getRandIndex(hash2+(secret_power2&0x1f)+1);
        _cancelbet(secret_power2,hash2,index2);
    }

    function notest2_lottery_single_deposit() public {
        vm.roll(++blocknumber);
        //_fake_play(0);
        (uint secret_power,) = _play(9); // hash can be restored later
        console.log("%x ticket", secret_power);
        _commit_reveal();
        (uint hash,) = _getHash(secret_power);
        (uint rand,uint index) = _getRandIndex(hash+(secret_power&0x1f)+1);
        _withdraw(secret_power,rand,index);
    }

    function test3_lottery_many_deposits() public {
        uint i;
        uint secret_power;
        uint hash;
        uint rand;
        uint index;
        vm.roll(++blocknumber);
        for (i = 0; i < 3; i++) {
            _fake_play(i);}
        vm.roll(++blocknumber);
        _commit_reveal();
        (uint secret_power2,uint hash2) = _play(4); // hash can be restored later
        for (; i < 20; i++) {
            _fake_play(i);}
        (,uint index2) = _getRandIndex(hash2+(secret_power2&0x1f)+1);
        _cancelbet(secret_power2,hash2,index2);
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
        _commit_reveal();
        (rand,index) = _getRandIndex(hash+(secret_power&0x1f)+1);
        _withdraw(secret_power,rand,index);
    }
}
