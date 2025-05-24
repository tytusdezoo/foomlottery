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
import {FoomLottery, IWithdraw, ICancel, IUpdate1, IUpdate3, IUpdate5, IUpdate11, IUpdate21, IUpdate44, IUpdate89, IUpdate179, IUniswapV2Router02, IWETH} from "src/FoomLottery.sol";

contract FoomLotteryTest is Test {
    FoomLottery public lottery;
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

    uint blocknumber = 1;
    uint revealSecret = 0;
    uint commitIndex = 0;
    uint commitBlockHash = 0;

    address private constant WETH_ADDRESS = 0x4200000000000000000000000000000000000006;
    address private constant FOOM_ADDRESS = 0x02300aC24838570012027E0A90D3FEcCEF3c51d2;
    address private constant ROUTER_ADDRESS = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24; // Uniswap V2 Router

    // Test vars
    address public me=payable(0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38);
    address public a1=payable(address(0x01));
    address public a2=payable(address(0x02));
    address public ag=payable(address(0x03));
    address public recipient = a1;
    address public relayer = payable(address(0x0));
    uint public fee = 0;
    uint public refund = 0;
    uint public invest = 0;
    uint public showGas = 1;
    uint constant testsize=5; // test size

    uint public          betMinETH = 1; //0.001 ether;
    uint public          betMin;
    uint public constant betPower1 = 10; // power of the first bet = 1024
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304

    //uint logBetHash = uint(keccak256(abi.encodePacked("LogBetHash(uint256,uint256,uint256)"))); // index,hash,rand
    uint LogBetIn = uint(keccak256(abi.encodePacked("LogBetIn(uint256,uint256)"))); // index,newHash
    uint LogCancel = uint(keccak256(abi.encodePacked("LogCancel(uint256)"))); // index
    uint LogUpdate = uint(keccak256(abi.encodePacked("LogUpdate(uint256,uint256,uint256)"))); // index,newRand,newRoot
    uint LogCommit = uint(keccak256(abi.encodePacked("LogCommit(uint256,uint256,uint256)"))); // index,newRand,newRoot
    uint LogHash = uint(keccak256(abi.encodePacked("LogHash(uint256)"))); // commitBlockHash

    function test() public { // can not run tests in parralel because of a common www repo
        check_funds();
        check_overflow();
        check_adminwithdraw();
        check_deposits();
        // get more FOOM to play with
        uint amount=betMinETH*2**23;
        IWETH(WETH_ADDRESS).deposit{value: amount}();
        IERC20(WETH_ADDRESS).approve(ROUTER_ADDRESS,amount);
        address[] memory path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = FOOM_ADDRESS;
        console.log("swap %d",amount);
        IUniswapV2Router02(ROUTER_ADDRESS).swapExactTokensForTokens(amount,0,path,address(this),block.timestamp);
        // now test with FOOM available
        check_hash();
        check_deposits();
        check_plays();
        check_cancel();
        check_max_updates();
        check_all_updates();
        check_odds();
        check_investments();
    }

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
        // get some info on Foom
        vm.createSelectFork(vm.rpcUrl("base")); // use data from Base
        //uint amount=0.001 ether; liquidity too small on base
        uint amount=betMinETH;
        IWETH(WETH_ADDRESS).deposit{value: amount}();
        IERC20(WETH_ADDRESS).approve(ROUTER_ADDRESS, amount);
        address[] memory path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = FOOM_ADDRESS;
        uint[] memory amounts = IUniswapV2Router02(ROUTER_ADDRESS).swapExactTokensForTokens(amount,0,path,address(this),block.timestamp);
        betMin = amounts[1];
        console.log(betMin,"betMin");
        // Deploy lottery contract.
        vm.roll(++blocknumber);
    	vm.recordLogs();
        lottery = new FoomLottery(withdraw, cancel, update1, update3, update5, update11, update21, update44, update89, update179, IERC20(FOOM_ADDRESS), IUniswapV2Router02(ROUTER_ADDRESS), betMin);
        lottery.changeGenerator(ag);
	init();
    }

    function getLogs() internal {
        Vm.Log[] memory entries = vm.getRecordedLogs();
        for (uint i = 0; i < entries.length; i++) {
            if (uint(entries[i].topics[0]) == LogCancel){
                uint betIndex = uint(entries[i].topics[1]);
                // append cancel to waiting list
                string[] memory inputs = new string[](3);
                inputs[0] = "forge-ffi-scripts/waiting.bash";
                inputs[1] = vm.toString(bytes32(betIndex)); // index
                inputs[2] = vm.toString(bytes32(uint(0x20))); // hash
                vm.ffi(inputs);}
            if (uint(entries[i].topics[0]) == LogBetIn){
                if(entries[i].topics[1]==0){ // first fixed bet
                    assertEq(entries[i].topics[2],0x0ce413930404e34f411b5117deff2a1a062c27b1dba271e133a9ffe91eeae520);}
                else{
                    // append to wating list file
                    string[] memory inputs = new string[](3);
                    inputs[0] = "forge-ffi-scripts/waiting.bash";
                    inputs[1] = vm.toString(bytes32(entries[i].topics[1])); // index
                    inputs[2] = vm.toString(bytes32(entries[i].topics[2])); // hash
                    vm.ffi(inputs);}}
            if (uint(entries[i].topics[0]) == LogUpdate){
                uint newIndex = uint(entries[i].topics[1]);
                uint newRand = uint(entries[i].topics[2]);
                uint newRoot = uint(entries[i].topics[3]);
                string[] memory inputs = new string[](6);
                inputs[0] = "node";
                inputs[1] = "forge-ffi-scripts/putLeaves.js";
                inputs[2] = vm.toString(bytes32(newIndex));
                inputs[3] = vm.toString(bytes32(newRand));
                inputs[4] = vm.toString(bytes32(newRoot));
                inputs[5] = vm.toString(bytes32(block.number)); // only for convenience
                vm.ffi(inputs);}
            if (uint(entries[i].topics[0]) == LogCommit){
                // reveal should react here and take blockhash and commit index from blockchain and contract
                commitIndex=uint(entries[i].topics[2]);
                }
            if (uint(entries[i].topics[0]) == LogHash){
                commitBlockHash=uint(entries[i].topics[1]);
                reveal();}}
    }

    function init() internal {
        string[] memory inputs = new string[](1);
        inputs[0] = "forge-ffi-scripts/init.bash";
        vm.ffi(inputs);
    }

    function cancelbet(uint secret_power,uint lastindex) internal {
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
        inputs[6] = vm.toString(bytes32(fee));
        inputs[7] = vm.toString(bytes32(refund));
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

    function commit() internal { // TODO: separate commit and reveal
        vm.roll(++blocknumber);
        getLogs();
        uint nextIndex=lottery.nextIndex();
        uint betsIndex=lottery.betsIndex();
        if(betsIndex==0){
          console.log("no tickets");
          return;}
        vm.roll(++blocknumber);
        revealSecret = uint(keccak256(abi.encodePacked(nextIndex)));
        uint _commitHash = uint(keccak256(abi.encodePacked(revealSecret)));
        uint commitGasStart = gasleft();
        uint maxUpdate=lottery.maxUpdate();
        vm.prank(ag);
        lottery.commit(_commitHash,maxUpdate);
        vm.roll(++blocknumber);
        vm.setBlockhash(blocknumber-1,bytes32(keccak256(abi.encodePacked(blocknumber-1))));
        uint commitGasUsed = commitGasStart - gasleft();
        if(0<showGas){ console.log("Gas used in _commit: %d", commitGasUsed); }
        vm.roll(++blocknumber);
        lottery.rememberHash();
        vm.roll(++blocknumber);
        getLogs();
    }

    function reveal() internal { // TODO: separate commit and reveal
        // compute update
        if(commitIndex==0){
          commitIndex=lottery.commitIndex();}
        if(commitBlockHash==0){
          commitIndex=lottery.commitBlockHash();
          if(commitBlockHash==0){
            return;}}
        uint newRand = uint128(uint(keccak256(abi.encodePacked(revealSecret,commitBlockHash))));
        uint hashesLength = updateSize(commitIndex);
        string[] memory inputs = new string[](5);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/update.js";
        inputs[2] = vm.toString(bytes32(commitIndex));
        inputs[3] = vm.toString(bytes32(hashesLength));
        inputs[4] = vm.toString(bytes32(newRand));
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
        uint newRoot = data[1];
        //console.log("after assert");
        uint revealGasUsed = revealGasStart - gasleft();
        if(0<showGas){ console.log("Gas used in update[%d].verifyProof: %d", hashesLength,revealGasUsed); }
        revealGasStart = gasleft();
        vm.prank(ag);
        lottery.reveal(revealSecret,pA,pB,pC,newRoot); // data[1]=newRoot
        revealGasUsed = revealGasStart - gasleft();
        if(0<showGas){ console.log("Gas used in _reveal[%d]: %d", hashesLength,revealGasUsed); }
        vm.roll(++blocknumber);
        getLogs();
    }

    function play(uint _power) public returns (uint secret_power,uint startIndex) {
        uint hash;
        uint startBlock;
        string[] memory inputs = new string[](3);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/getHash.js";
        inputs[2] = vm.toString(bytes32(_power));
        bytes memory result = vm.ffi(inputs);
        (secret_power, hash, startIndex, startBlock) = abi.decode(result, (uint, uint, uint, uint));
        uint amount = betMin * (2 + 2**_power);
        uint balance=IERC20(FOOM_ADDRESS).balanceOf(address(this));
        if(balance>amount){
          console.log("%d, try play with FOOM",balance);
          uint gasStart = gasleft();
          IERC20(FOOM_ADDRESS).approve(address(lottery),amount);
          uint gasUsed = gasStart - gasleft();
          if(0<showGas){ console.log("Gas used in approve: %d", gasUsed); }
               gasStart = gasleft();
          lottery.play(hash,_power);
               gasUsed = gasStart - gasleft();
          if(0<showGas){ console.log("Gas used in _playFOOM: %d", gasUsed); } }
        else{
          console.log("%d, try playETH with ETH",balance);
          uint amountETH = betMinETH * (2 + 2**_power);
          amountETH=amountETH+amountETH>>0; // 4: (1+1/16) 106% ,5: (1+1/32) 103%
          uint gasStart = gasleft();
          lottery.playETH{value: amountETH}(hash,_power); 
          uint gasUsed = gasStart - gasleft();
          if(0<showGas){ console.log("Gas used in _playETH: %d", gasUsed); } }
        console.log("%x,%x ticket (%d)", secret_power,startIndex,amount);
        getLogs();
        return (secret_power,startIndex);
    }

    function fakeplay(uint i) public {
        uint hash = uint(uint240(uint(keccak256(abi.encode(i))))<<5);
        uint amount = 3*betMin;
        uint balance=IERC20(FOOM_ADDRESS).balanceOf(address(this));
        if(balance>amount){
          IERC20(FOOM_ADDRESS).approve(address(lottery),amount);
          lottery.play(hash,0);}
        else{
          amount=3*betMinETH*2;
          lottery.playETH{value: amount}(hash,0);}
        getLogs();
    }

    function fakeplayFOOM(uint i) public {
        uint hash = uint(uint240(uint(keccak256(abi.encode(i))))<<5);
        lottery.play(hash,0);
        getLogs();
    }

    function fakeplayETH(uint i) public {
        uint hash = uint(uint240(uint(keccak256(abi.encode(i))))<<5);
        uint amount=3*betMinETH*2;
        lottery.playETH{value: amount}(hash,0);
        getLogs();
    }

    function view_status() view public returns(uint) {
        uint lwallet=IWETH(FOOM_ADDRESS).balanceOf(address(lottery));
	uint period=lottery.dividendPeriod();
        uint pbets=lottery.periodBets(period-1);
        uint pshares=lottery.periodShares(period-1);
        uint cbalance=lottery.currentBalance();
        console.log("lottery: %d (%d,%d)",lwallet,block.number,period);
        console.log("%d: Bets: %d Shares: %d",period-1,pbets,pshares);
        uint sbalance=0;
        address[3] memory who=[a1,a2,ag];
        for(uint i=0;i<who.length;i++){
            uint wallet=IWETH(FOOM_ADDRESS).balanceOf(who[i]);
            uint balance=lottery.walletBalanceOf(who[i]);
            sbalance+=balance;
            console.log("%d wallet: %d,balance: %d",i,wallet,balance);}
        console.log("cBalance: %d sBalance: %d",cbalance,sbalance);
        return(lwallet);
    }

    function check_adminwithdraw() public {
        console.log('check_adminwithdraw START');
        getLogs();
        (uint secret_power,uint startIndex) = play(10);
        vm.expectRevert();
        lottery.close();
        commit();
        vm.expectRevert();
        lottery.adminwithdraw();
        lottery.close();
        lottery.reopen();
        lottery.close();
        console.log(blocknumber,"blocknumber");
        blocknumber+=4*60*24*365*2+4;
        vm.roll(++blocknumber);
        console.log(blocknumber,"blocknumber");
        view_status();
        lottery.adminwithdraw();
        view_status();
        _withdraw(secret_power,startIndex);
        view_status();
        lottery.reopen();
        console.log('check_adminwithdraw OK');
    }

    function check_funds() public {
        console.log('check_funds START');
        vm.expectRevert();
        lottery.play(0x20,0);
        vm.expectRevert();
        lottery.playETH{value: 1}(0x20,0);
        console.log('check_funds OK');
    }

    function check_hash() public {
        console.log('check_funds START');
        vm.expectRevert();
        lottery.play(0,0);
        uint amount=3*betMinETH*2;
        vm.expectRevert();
        lottery.playETH{value: amount}(0,0);
        console.log('check_funds OK');
    }

    function check_overflow() public {
        console.log('check_overflow START');
        commit();
        commit();
        for (uint i=0; i < 250; i++) { // betsMax
            fakeplay(i);}
        vm.expectRevert();
        fakeplayETH(251);
        commit();
        console.log('check_overflow OK');
    }

    function check_investments() public {
        console.log('check_investments START');
        getLogs();
        view_status();
        showGas=0;
        uint secret_power;
        uint startIndex;
        uint periodBlocks=lottery.periodBlocks();

        vm.roll(++blocknumber);
        lottery.updateDividendPeriod();
        console.log("");

        view_status();
        (secret_power,startIndex) = play(10);
        commit();
        invest = 2000;
        recipient=a1;
        _withdraw(secret_power,startIndex);

        blocknumber+=periodBlocks+1;
        vm.roll(blocknumber);
        lottery.updateDividendPeriod();
        console.log("");

        view_status();
        (secret_power,startIndex) = play(10);
        commit();
        invest = 0;
        recipient=a2;
        _withdraw(secret_power,startIndex);

        blocknumber+=periodBlocks+1;
        vm.roll(blocknumber);
        lottery.updateDividendPeriod();
        console.log("");

        view_status();
        (secret_power,startIndex) = play(0);
        commit();
        invest = 0;
        recipient=a2;
        _withdraw(secret_power,startIndex);

        blocknumber+=periodBlocks+1;
        vm.roll(blocknumber);
        lottery.updateDividendPeriod();
        console.log("");

        view_status();
        (secret_power,startIndex) = play(16);
        commit();
        invest = 0;
        recipient=a2;//a1;
        _withdraw(secret_power,startIndex);

        blocknumber+=periodBlocks+1;
        vm.roll(blocknumber);
        lottery.updateDividendPeriod();
        console.log("");

        view_status();
        (secret_power,startIndex) = play(16);
        commit();
        invest = 0;
        recipient=a2;
        _withdraw(secret_power,startIndex);

        blocknumber+=periodBlocks+1;
        vm.roll(blocknumber);
        lottery.updateDividendPeriod();
        console.log("");

        view_status();

        blocknumber+=periodBlocks+1;
        vm.roll(blocknumber);
        lottery.updateDividendPeriod();
        console.log("");

        view_status();
        console.log("payout a2");
        vm.prank(a2);
        //lottery.payOut(500);
        lottery.payOut(500);
        console.log("payout a1");
        vm.prank(a1);
        lottery.payOut(500);

        blocknumber+=periodBlocks+1;
        vm.roll(blocknumber);
        lottery.updateDividendPeriod();
        console.log("");

        view_status();
        console.log("payout ag");
        vm.prank(ag);
        lottery.payOut(0);

        blocknumber+=periodBlocks+1;
        vm.roll(blocknumber);
        lottery.updateDividendPeriod();
        console.log("");

        uint ballot=view_status();
 
        uint vol=2*(2**10+2)+2*(2**16+2)+3;
        console.log("\nvol: %d, lot: %d, fee: %d/10000",vol,ballot,ballot*10000/vol);
        console.log('check_investments OK');
    }

    function check_odds() public {
        console.log('check_odds START');
        getLogs();
        uint[testsize][3] memory secret; // reverse order of dimensions in solidity :-)
        uint[testsize][3] memory startIndex;
        uint i;
        uint j;
        showGas=0;
        for(j=0;j<3;j++){
            for(i=0;i<testsize;i++){
                vm.roll(++blocknumber);
                (secret[j][i],startIndex[j][i]) = play(9+j*6);}} // hash can be restored later
        commit();
        for(j=0;j<3;j++){
            console.log("test: %d, num %d",j,testsize);
            for(i=0;i<testsize;i++){
                _withdraw(secret[j][i],startIndex[j][i]);}}
        console.log('check_odds OK');
    }

    function check_deposits() public {
        console.log('check_deposits START');
        getLogs();
        uint secret_power;
        uint startIndex;
        vm.roll(++blocknumber);
        (secret_power,startIndex) = play(10);
        commit();
        _withdraw(secret_power,startIndex);

        vm.roll(++blocknumber);
        (secret_power,startIndex) = play(16);
        commit();
        _withdraw(secret_power,startIndex);

        vm.roll(++blocknumber);
        (secret_power,startIndex) = play(22);
        commit();
        _withdraw(secret_power,startIndex);

        vm.roll(++blocknumber);
        fakeplay(1);
        fakeplay(2);
        getLogs();
        console.log('check_deposits OK');
    }

    function check_plays() public {
        console.log('check_plays START');
        getLogs();
        uint i;
        uint secret_power;
        uint startIndex;
        vm.roll(++blocknumber);
        for (i = 0; i < 3; i++) {
            fakeplay(i);}
        vm.roll(++blocknumber);
        commit();
        (secret_power,startIndex) = play(1); // hash can be restored later
        for (; i < 20; i++) {
            fakeplay(i);}
        cancelbet(secret_power,startIndex);
        commit();
        (secret_power,startIndex) = play(2);
        for (; i < 60; i++) {
            fakeplay(i);}
        commit();
        commit();
        _withdraw(secret_power,startIndex);
        (secret_power,startIndex) = play(3);
        for (; i < 130; i++) {
            fakeplay(i);}
        commit();
        commit();
        _withdraw(secret_power,startIndex);
        console.log('check_plays OK');
    }

    function check_cancel() public {
        console.log('check_cancel START');
        getLogs();
        vm.roll(++blocknumber);
        fakeplay(0);
        fakeplay(0);
        commit();
        (uint secret_power,uint startIndex) = play(4); // hash can be restored later
        fakeplay(0);
        fakeplay(0);
        cancelbet(secret_power,startIndex);
        fakeplay(0);
        commit();
        console.log('check_cancel OK');
    }

    function check_all_updates() public {
        console.log('check_updates START');
        getLogs();
        uint[8] memory sizes=[uint(1),uint(2),uint(4),uint(10),uint(20),uint(43),uint(88),uint(178)];
        for(uint j=0;j<8;j++){
          for(uint i=0;i<sizes[j];i++){
            fakeplay(j*8+i);}
          uint start = vm.unixTime();
          commit();
          uint end = vm.unixTime();
          console.log("time[%d]: %d",sizes[j],end - start);}
        console.log('check_updates OK');
    }
    
    function check_max_updates() public {
        console.log('check_max_updates START');
        getLogs();
        uint[2] memory sizes=[uint(180),uint(180)];
        for(uint j=0;j<2;j++){
          for(uint i=0;i<sizes[j];i++){
            fakeplay(j*8+i);}
          play(10);
          uint start = vm.unixTime();
          commit();
          uint end = vm.unixTime();
          console.log("time[%d]: %d",sizes[j],end - start);}
        fakeplay(2);
        console.log('check_max_updates OK');
    }
    
}
