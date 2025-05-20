// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {WithdrawG16Verifier} from "src/Withdraw.sol";
import {CancelBetG16Verifier} from "src/CancelBet.sol";
import {Update1G16Verifier} from "src/Update1.sol";
import {Update3G16Verifier} from "src/Update3.sol";
import {Update5G16Verifier} from "src/Update5.sol";
import {Update11G16Verifier} from "src/Update11.sol";
import {Update21G16Verifier} from "src/Update21.sol";
import {Update44G16Verifier} from "src/Update44.sol";
import {Update89G16Verifier} from "src/Update89.sol";
import {Update179G16Verifier} from "src/Update179.sol";
import {IWithdraw, ICancel, IUpdate1, IUpdate3, IUpdate5, IUpdate11, IUpdate21, IUpdate44, IUpdate89, IUpdate179} from "src/Lottery.sol";
import {EthLottery} from "src/EthLottery.sol";

contract EthLotteryTest is Test {
    uint public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    EthLottery public lottery;
    IWithdraw public withdraw;
    ICancel public cancel;
    IUpdate1 public update1;
    IUpdate3 public update3;
    IUpdate5 public update5;
    IUpdate11 public update11;
    IUpdate21 public update21;
    IUpdate44 public update44;
    IUpdate89 public update89;
    IUpdate179 public update179;

    uint newRoot;
    uint blocknumber = 1;
    uint oldIndex = 0;
    uint commitIndex=0;
    Vm.Log[] public allLeaves;

    // Test vars
    address public constant relayer = payable(address(0x0));
    address public me=payable(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
    address public ag=payable(address(0x10));
    address public a1=payable(address(0x01));
    address public a2=payable(address(0x02));
    address public recipient = a1;
    uint public fee = 0;
    uint public refund = 0;
    uint public invest = 0;
    uint public showGas = 1;
    uint constant testsize=5; // test size

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
        update3 = IUpdate3(address(new Update3G16Verifier()));
        update5 = IUpdate5(address(new Update5G16Verifier()));
        update11 = IUpdate11(address(new Update11G16Verifier()));
        update21 = IUpdate21(address(new Update21G16Verifier()));
        update44 = IUpdate44(address(new Update44G16Verifier()));
        update89 = IUpdate89(address(new Update89G16Verifier()));
        update179 = IUpdate179(address(new Update179G16Verifier()));
        // Deploy lottery contract.
        vm.roll(++blocknumber);
    	vm.recordLogs();
        lottery = new EthLottery(withdraw, cancel, update1, update3, update5, update11, update21, update44, update89, update179, IERC20(address(0)), betMin);
    }

    function _getLogs() internal {
        Vm.Log[] memory entries = vm.getRecordedLogs();
        for (uint i = 0; i < entries.length; i++) {
            if (uint(entries[i].topics[0]) == LogCancel){
                uint index = uint(entries[i].topics[1]);
                allLeaves[index].topics[2]=bytes32(uint(0x20));}
            if (uint(entries[i].topics[0]) == LogBetIn){
                assertEq(uint(allLeaves.length),uint(entries[i].topics[1]),"lost bet?");
                string[] memory inputs = new string[](3);
                if(oldIndex==0){
                    inputs[0] = "mkdir";
                    inputs[1] = "-p";
                    inputs[2] = "www";
                    vm.ffi(inputs);
                    inputs[0] = "cp";
                    inputs[1] = "/dev/null";
                    inputs[2] = "www/waiting.csv";
                    vm.ffi(inputs);
                    assertEq(entries[i].topics[2],0x0ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae520);
                    entries[i].topics[0]=0; // rand
                    entries[i].topics[1]=0x24d599883f039a5cb553f9ec0e5998d58d8816e823bd556164f72aef0ef7d9c0; // leaf
                    oldIndex=1;}
                else{
                    // append to wating list file
                    inputs[0] = "forge-ffi-scripts/waiting.bash";
                    inputs[1] = vm.toString(bytes32(entries[i].topics[1])); // index
                    inputs[2] = vm.toString(bytes32(entries[i].topics[2])); // hash
                    vm.ffi(inputs);
                } 
                allLeaves.push(entries[i]);}
            if (uint(entries[i].topics[0]) == LogUpdate){
                uint newIndex = uint(entries[i].topics[1]);
                uint newRand = uint(entries[i].topics[2]);
                uint hashesLength = newIndex-oldIndex;
                string[] memory inputs = new string[](6+hashesLength);
                inputs[0] = "node";
                inputs[1] = "forge-ffi-scripts/getLeaves.js";
                //inputs[2] = vm.toString(bytes32(oldIndex));
                inputs[2] = vm.toString(oldIndex);
                inputs[3] = vm.toString(block.number);
                inputs[4] = vm.toString(bytes32(newRoot));
                inputs[5] = vm.toString(bytes32(newRand));
                for (uint j = 0; j < hashesLength; j++) {
                    inputs[6+j] = vm.toString(bytes32(allLeaves[oldIndex+j].topics[2]));}
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

    function _cancelbet(uint secret_power,uint lastindex) internal {
        string[] memory inputs = new string[](4);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/cancelBet.js";
        inputs[2] = vm.toString(bytes32(secret_power));
        inputs[3] = vm.toString(bytes32(lastindex));
        bytes memory result = vm.ffi(inputs);
        (uint[2] memory pA, uint[2][2] memory pB, uint[2] memory pC,uint[1] memory data, uint index) = abi.decode(result, (uint[2], uint[2][2], uint[2], uint[1], uint));
        uint gasStart = gasleft();
        assertTrue(cancel.verifyProof(pA,pB,pC,data));
        uint gasUsed = gasStart - gasleft();
        if(0<showGas){ console.log("Gas used in cancel.verifyProof: %d", gasUsed); }
        gasStart = gasleft();
        console.log(index,"cancel index");
        lottery.cancelbet(pA,pB,pC,index,recipient);
        gasUsed = gasStart - gasleft();
        if(0<showGas){ console.log("Gas used in _cancelbet: %d", gasUsed); }
    }

    function _withdraw(uint secret_power, uint lastindex) internal {
        string[] memory inputs = new string[](8);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/withdraw.js";
        inputs[2] = vm.toString(bytes32(secret_power));
        inputs[3] = vm.toString(bytes32(lastindex));
        inputs[4] = vm.toString(recipient);
        inputs[5] = vm.toString(relayer);
        inputs[6] = "0x0";
        inputs[7] = "0x0";
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
        if(0<showGas){ console.log("Gas used in withdraw.verifyProof: %d", gasUsed); }
        gasStart = gasleft();
        lottery.collect( pA, pB, pC, root, nullifierHash, recipient, relayer, 0, 0, rewardbits, invest);
        gasUsed = gasStart - gasleft();
        //if(reward>0){ //assertGt(recipient.balance,(reward*94)/100); //console.log("Balance: %d\n",recipient.balance); }
        if(0<showGas){ console.log("Gas used in _withdraw: %d", gasUsed); }
    }

    function updateSize(uint commitSize) pure public returns (uint) {
        if(commitSize<=1){
          return(1);}
        if(commitSize<=3){
          return(3);}
        if(commitSize<=5){
          return(5);}
        if(commitSize<=11){
          return(11);}
        if(commitSize<=21){
          return(21);}
        if(commitSize<=44){
          return(44);}
        if(commitSize<=89){
          return(89);}
        if(commitSize<=179){
          return(179);}
        revert("bad commitSize");
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
        uint maxUpdate=lottery.maxUpdate();
        lottery.commit(_commitHash,maxUpdate);
        uint commitGasUsed = commitGasStart - gasleft();
        if(0<showGas){ console.log("Gas used in _commit: %d", commitGasUsed); }
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
        else if(hashesLength==3){
          uint[4+3] memory pubdata;for(uint i=0;i<4+3;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update3.verifyProof(pA,pB,pC,pubdata));}
        else if(hashesLength==5){
          uint[4+5] memory pubdata;for(uint i=0;i<4+5;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update5.verifyProof(pA,pB,pC,pubdata));}
        else if(hashesLength==11){
          uint[4+11] memory pubdata;for(uint i=0;i<4+11;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update11.verifyProof(pA,pB,pC,pubdata));}
        else if(hashesLength==21){
          uint[4+21] memory pubdata;for(uint i=0;i<4+21;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update21.verifyProof(pA,pB,pC,pubdata));}
        else if(hashesLength==44){
          uint[4+44] memory pubdata;for(uint i=0;i<4+44;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update44.verifyProof(pA,pB,pC,pubdata));}
        else if(hashesLength==89){
          uint[4+89] memory pubdata;for(uint i=0;i<4+89;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update89.verifyProof(pA,pB,pC,pubdata));}
        else if(hashesLength==179){
          uint[4+179] memory pubdata;for(uint i=0;i<4+179;i++){pubdata[i]=data[i];} revealGasStart = gasleft();
          assertTrue(update179.verifyProof(pA,pB,pC,pubdata));}
        else{
          revert("bad commitSize");}
        newRoot = data[1];
        //console.log("after assert");
        uint revealGasUsed = revealGasStart - gasleft();
        if(0<showGas){ console.log("Gas used in update[%d].verifyProof: %d", hashesLength,revealGasUsed); }
        revealGasStart = gasleft();
        lottery.reveal(_revealSecret,pA,pB,pC,newRoot); // data[1]=newRoot
        revealGasUsed = revealGasStart - gasleft();
        if(0<showGas){ console.log("Gas used in _reveal[%d]: %d", hashesLength,revealGasUsed); }
        vm.roll(++blocknumber);
        commitIndex=0;
        _getLogs();
    }

    function _play(uint _power) internal returns (uint secret_power,uint lastindex) {
        uint hash;
        string[] memory inputs = new string[](3);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/getHash.js";
        inputs[2] = vm.toString(bytes32(_power));
        bytes memory result = vm.ffi(inputs);
        (secret_power, hash, lastindex) = abi.decode(result, (uint, uint, uint));
        uint gasStart = gasleft();
        lottery.play{value: betMin * (2 + 2**_power)}(hash,_power);
        uint gasUsed = gasStart - gasleft();
        if(0<showGas){ console.log("Gas used in _play: %d", gasUsed); }
        _getLogs();
        return (secret_power,lastindex);
    }

    function _fake_play(uint i) internal {
        uint hash = uint(uint240(uint(keccak256(abi.encode(i))))<<5);
        lottery.play{value: 3*betMin}(hash,0);
        _getLogs();
    }

    function view_status() view public {
        uint ballot=address(lottery).balance;
        console.log("\nlottery: %d (%d,%d)",ballot,block.number,lottery.dividendPeriod());
        address[2] memory who=[a1,a2];
        for(uint i=0;i<who.length;i++){
            uint balance=who[i].balance;
            uint wallet=lottery.walletBalanceOf(who[i]);
            uint shares=lottery.walletSharesOf(who[i]);
            uint wperiod=lottery.walletWithdrawPeriodOf(who[i]);
            console.log("%d balance: %d,wallet: %d",i,balance,wallet);
            console.log("%d shares: %d,withdrawperiod: %d",i,shares,wperiod);}
    }

    function notest0_investments() public {
        // console.log("period %d",periodBlocks);
        // console.log("me %x",msg.sender); // 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38
        view_status();
        showGas=0;
        uint i=0;
        uint secret_power;
        uint lastindex;
        uint periodBlocks=lottery.periodBlocks();
        vm.roll(++blocknumber);

        (secret_power,lastindex) = _play(10);
        _commit_reveal();
        invest = 1000;
        recipient=a1;
        _withdraw(secret_power,lastindex);
        view_status(); // p1

        for (i = 0; i < 3; i++) {
            _fake_play(i);}
        blocknumber+=periodBlocks;
        vm.roll(blocknumber);
        (secret_power,lastindex) = _play(10);
        _commit_reveal();
        invest = 0;
        recipient=a2;
        _withdraw(secret_power,lastindex);
        view_status(); // p1

        blocknumber+=periodBlocks;
        vm.roll(blocknumber);
        (secret_power,lastindex) = _play(10);
        for (i = 0; i < 3; i++) {
            _fake_play(i);}
        _commit_reveal();
        invest = 0;
        recipient=a2;
        _withdraw(secret_power,lastindex);
        view_status(); // p3

        blocknumber+=periodBlocks+1;
        vm.roll(blocknumber);
        vm.prank(a2);
        lottery.payOut();
        vm.prank(a1);
        lottery.payOut();
        vm.roll(++blocknumber);
        view_status(); // p3

    }

    function test1_lottery_cancel() public {
        vm.roll(++blocknumber);
        _fake_play(0);
        (uint secret_power,) = _play(10); // hash can be restored later
        console.log("%x ticket", secret_power);
        _commit_reveal();
        (uint secret_power2,uint lastindex2) = _play(4); // hash can be restored later
        console.log("%x ticket", secret_power2);
        _cancelbet(secret_power2,lastindex2);
    }

    function notest5_ods() public {
        uint[testsize][3] memory secret; // reverse order of dimensions in solidity :-)
        uint[testsize][3] memory lastindex;
        uint i;
        uint j;
        showGas=0;
        for(j=0;j<3;j++){
            for(i=0;i<testsize;i++){
                vm.roll(++blocknumber);
                (secret[j][i],lastindex[j][i]) = _play(9+j*6);}} // hash can be restored later
        _commit_reveal();
        for(j=0;j<3;j++){
            console.log("test: %d, num %d",j,testsize);
            for(i=0;i<testsize;i++){
                _withdraw(secret[j][i],lastindex[j][i]);}}
    }

    function test2_lottery_single_deposit() public {
        vm.roll(++blocknumber);
        //_fake_play(0);
        (uint secret_power1,uint lastindex1) = _play(10); // hash can be restored later
        console.log("%x ticket", secret_power1);
        _commit_reveal();
        _withdraw(secret_power1,lastindex1);

        vm.roll(++blocknumber);
        //_fake_play(0);
        (uint secret_power2,uint lastindex2) = _play(16); // hash can be restored later
        console.log("%x ticket", secret_power2);
        _commit_reveal();
        _withdraw(secret_power2,lastindex2);

        vm.roll(++blocknumber);
        //_fake_play(0);
        (uint secret_power3,uint lastindex3) = _play(22); // hash can be restored later
        console.log("%x ticket", secret_power3);
        _commit_reveal();
        _withdraw(secret_power3,lastindex3);

        vm.roll(++blocknumber);
        _fake_play(1);
        _fake_play(2);
        _getLogs();
    }

    function notest9_179_updates() public {
        uint[2] memory sizes=[uint(180),uint(180)];
        for(uint j=0;j<2;j++){
          for(uint i=0;i<sizes[j];i++){
            _fake_play(j*8+i);}
          uint start = vm.unixTime();
          _commit_reveal();
          uint end = vm.unixTime();
          console.log("time[%d]: %d",sizes[j],end - start);}
    }
    
    function notest9_updates() public {
        uint[8] memory sizes=[uint(1),uint(2),uint(4),uint(10),uint(20),uint(43),uint(88),uint(178)];
        for(uint j=0;j<8;j++){
          console.log("blocknumber: %d",blocknumber);
          for(uint i=0;i<sizes[j];i++){
            _fake_play(j*8+i);}
          uint start = vm.unixTime();
          _commit_reveal();
          uint end = vm.unixTime();
          console.log("time[%d]: %d",sizes[j],end - start);}
    }
    
    function notest3_lottery_many_deposits() public {
        uint i;
        uint secret_power;
        uint lastindex;
        vm.roll(++blocknumber);
        for (i = 0; i < 3; i++) {
            _fake_play(i);}
        vm.roll(++blocknumber);
        _commit_reveal();
        (secret_power,lastindex) = _play(4); // hash can be restored later
        for (; i < 20; i++) {
            _fake_play(i);}
        _cancelbet(secret_power,lastindex);
        _commit_reveal();
        (secret_power,lastindex) = _play(10);
        for (; i < 60; i++) {
            _fake_play(i);}
        _commit_reveal();
        _commit_reveal();
        _withdraw(secret_power,lastindex);
        (secret_power,lastindex) = _play(2);
        for (; i < 130; i++) {
            _fake_play(i);}
        _commit_reveal();
        _commit_reveal();
        _commit_reveal();
        _withdraw(secret_power,lastindex);
    }
}
