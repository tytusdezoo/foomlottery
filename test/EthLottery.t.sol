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
    uint256 public constant FIELD_SIZE = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    EthLottery public lottery;
    IWithdraw public withdraw;
    ICancel public cancel;

    uint blocknumber = 1;
    Vm.Log[] public allEntries;

    // Test vars
    address public constant recipient = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address public constant relayer = address(0);
    uint256 public constant fee = 0;
    uint256 public constant refund = 0;

    uint public constant betMin = 1; // TODO: compute correct value
    uint public constant betPower1 = 10; // power of the first bet = 1024
    uint public constant betPower2 = 16; // power of the second bet = 65536
    uint public constant betPower3 = 22; // power of the third bet = 4194304

    struct PlayData {
        uint secret;
        uint mask;
        uint mimcR;
        uint mimcC;
        uint rand;
        bytes32 leaf;
    }

    struct CollectData {
        uint256[2] pA;
        uint256[2][2] pB;
        uint256[2] pC;
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
        uint _mask,
        uint _rand,
        address _recipient,
        address _relayer,
        bytes32[] memory leaves
    ) internal returns (uint256[2] memory pA, uint256[2][2] memory pB, uint256[2] memory pC, uint root, uint nullifierHash, uint rew1, uint rew2, uint rew3) {
        string[] memory inputs = new string[](9 + leaves.length);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/generateWitness.js";
        inputs[2] = vm.toString(bytes32(_secret));
        inputs[3] = vm.toString(bytes32(_mask));
        inputs[4] = vm.toString(bytes32(_rand));
        inputs[5] = vm.toString(_recipient);
        inputs[6] = vm.toString(_relayer);
        inputs[7] = "0";
        inputs[8] = "0";

        for (uint256 i = 0; i < leaves.length; i++) {
            inputs[9 + i] = vm.toString(leaves[i]);
        }

        bytes memory result = vm.ffi(inputs);
        (pA, pB, pC, root, nullifierHash, rew1, rew2, rew3) =
            abi.decode(result, (uint256[2], uint256[2][2], uint256[2], uint, uint, uint, uint, uint));
        return (pA, pB, pC, root, nullifierHash, rew1, rew2, rew3);
    }

    function _getCommitment(uint _amount) internal returns (uint commitment, uint secret, uint mask, uint mimcR, uint mimcC) {
        string[] memory inputs = new string[](3);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/generateCommitment.js";
        inputs[2] = vm.toString(bytes32(_amount));

        bytes memory result = vm.ffi(inputs);
        (commitment, secret, mask, mimcR, mimcC) = abi.decode(result, (uint, uint, uint, uint, uint));
	    //console.log("%x commmitment",commitment);
	    //console.log("%x secret",secret);
	    //console.log("%x mask",mask);
	    //console.log("%x mimcR",mimcR);
	    //console.log("%x mimcC",mimcC);
        return (commitment, secret, mask, mimcR, mimcC);
    }

    function _play_and_get_data(uint _amount) internal returns (PlayData memory) {
        uint256 gasStart = gasleft();
        // 1. Generate commitment and deposit
        (uint commitment, uint secret, uint mask, uint mimcR, uint mimcC) = _getCommitment(_amount);
        lottery.play{value: _amount*betMin}(commitment,0);
        
        // 1.5. Process bets by admin
        (uint betsIndex, uint commitCount, uint commitBlock,uint commitHash)=lottery.getStatus();
        assertEq(commitBlock,0);
        uint _revealSecret = uint(keccak256(abi.encodePacked(commitCount)));
        uint _commitHash = uint(keccak256(abi.encodePacked(_revealSecret)));
        lottery.commit(_commitHash);
        vm.roll(++blocknumber);

        uint commitCountNew;
        (betsIndex, commitCountNew, commitBlock,commitHash)=lottery.getStatus();
        assertGt(commitBlock,0);
        assertEq(commitHash,_commitHash);
        assertEq(commitCount+1,commitCountNew);
        (uint rand,uint leaf)=lottery.reveal(_revealSecret);
        vm.roll(++blocknumber);
        
        (betsIndex, commitCount, commitBlock,commitHash)=lottery.getStatus();
        assertEq(commitBlock,0);
        
        uint256 gasUsed = gasStart - gasleft();
        console.log("Gas used in _play_and_get_data: %d", gasUsed);
        
        return PlayData({
            secret: secret,
            mask: mask,
            mimcR: mimcR,
            mimcC: mimcC,
            rand: rand,
            leaf: bytes32(leaf)
        });
    }

    function _get_collect_data(uint secret, uint mask, uint rand, bytes32[] memory leaves) internal returns (CollectData memory) {
        (uint256[2] memory pA, uint256[2][2] memory pB, uint256[2] memory pC, uint root, uint nullifierHash, uint rew1, uint rew2, uint rew3) =
            _getWitnessAndProof(secret, mask, rand, recipient, relayer, leaves);
        
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

    function _collect(uint secret, uint mask, uint rand, bytes32[] memory leaves) internal {
        uint256 gasStart = gasleft();
        
        CollectData memory data = _get_collect_data(secret, mask, rand, leaves);
        
        uint _reward = betMin * data.rew1 * 2**betPower1 +
                       betMin * data.rew2 * 2**betPower2 +
                       betMin * data.rew3 * 2**betPower3;
        console.log("%d reward",_reward);
        
        assertTrue(withdraw.verifyProof(
            data.pA,
            data.pB,
            data.pC,
            [uint256(data.root),uint256(data.nullifierHash),data.rew1,data.rew2,data.rew3,uint256(uint160(recipient)),uint256(uint160(relayer)),fee,refund]
        ));
        
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
        
        if(_reward>0){
            assertGt(recipient.balance,(_reward*94)/100);
        }
        
        uint256 gasUsed = gasStart - gasleft();
        console.log("Gas used in _collect: %d", gasUsed);
    }

    function _fake_play_and_get_leaf(uint i) internal /*returns (bytes32)*/ {
        uint _amount=3;
        uint commitment = uint(uint256(keccak256(abi.encode(i))) % FIELD_SIZE);
        lottery.play{value: _amount*betMin}(commitment,0);
        /*
        (,uint commitCount,,)=lottery.getStatus();
        uint _revealSecret = uint(keccak256(abi.encodePacked(commitCount)));
        uint _commitHash = uint(keccak256(abi.encodePacked(_revealSecret)));
        vm.roll(++blocknumber);
        lottery.commit(_commitHash);
        vm.roll(++blocknumber);
        //(uint rand,uint leaf)=lottery.reveal(_revealSecret);
        (,uint leaf)=lottery.reveal(_revealSecret);
        vm.roll(++blocknumber);
        return(bytes32(leaf));
        */
    }

    function _commit_reveal() internal {
        uint256 gasStart = gasleft();
        (,uint commitCount,,)=lottery.getStatus();
        uint _revealSecret = uint(keccak256(abi.encodePacked(commitCount)));
        uint _commitHash = uint(keccak256(abi.encodePacked(_revealSecret)));
        vm.roll(++blocknumber);
        lottery.commit(_commitHash);
        vm.roll(++blocknumber);
        lottery.reveal(_revealSecret);
        vm.roll(++blocknumber);
        uint256 gasUsed = gasStart - gasleft();
        console.log("Gas used in _commit_reveal: %d", gasUsed);
    }

    function _notest_mimc() public view {
        uint inL=1;
        uint inR=0;
        uint k=0;
        console.log("%x inL",inL);
        console.log("%x inR",inR);
        console.log("%x k",k);
        (uint oL,uint oR)=lottery.MiMCSponge(inL,inR,k);
        console.log("%x oL",oL);
        console.log("%x oR",oR);
    }

    function _get_leaves(uint inR, uint inC) internal returns (uint,uint,uint,uint,bytes32[] memory) {
        Vm.Log[] memory entries = vm.getRecordedLogs();
        // push all new entries to allEntries
        for (uint256 i = 0; i < entries.length; i++) {
            allEntries.push(entries[i]);
        }
        uint maxLeaves = allEntries.length/2;
        bytes32[] memory leaves = new bytes32[](maxLeaves);
        //console.log("%d allEntries.length",allEntries.length);
        uint leavesCount = 0;
        uint index = 2**32;
        uint mimcR;
        uint mimcC;
        uint rand; // newhash
        uint currentLevelHash; // leaf
        // LogBetIn(uint indexed index,uint R,uint C)
        // LogBetHash(uint indexed index,uint newhash,uint currentLevelHash)
        uint logBetIn = uint(keccak256(abi.encodePacked("LogBetIn(uint256,uint256,uint256)")));
        //console.log("%x logBetIn",logBetIn);
        uint logBetHash = uint(keccak256(abi.encodePacked("LogBetHash(uint256,uint256,uint256)")));
        //console.log("%x logBetHash",logBetHash);
        for (uint256 i = 0; i < allEntries.length; i++) {
            //console.log("%x topic",uint(allEntries[i].topics[0]));
            if (uint(allEntries[i].topics[0]) == logBetIn){
                //console.log("%x topic1",uint(allEntries[i].topics[1]));
                //console.log("%x topic2",uint(allEntries[i].topics[2]));
                //console.log("%x topic3",uint(allEntries[i].topics[3]));
                if (uint(allEntries[i].topics[2]) == inR && uint(allEntries[i].topics[3]) == inC) {
                    index = uint(allEntries[i].topics[1]);
                    mimcR = uint(allEntries[i].topics[2]); // not used
                    mimcC = uint(allEntries[i].topics[3]); // not used
                    //console.log("%x index",index);
                }
            }
            if (uint(allEntries[i].topics[0]) == logBetHash){
                leaves[leavesCount++] = allEntries[i].topics[3];
                if (uint(allEntries[i].topics[1]) == index) {
                    rand = uint(allEntries[i].topics[2]);
                    currentLevelHash = uint(allEntries[i].topics[3]);
                    //console.log("%x rand",rand);
                }
            }

        }
        return (index,rand,currentLevelHash,leavesCount,leaves);
    }

    function test_lottery_single_deposit() public {
        PlayData memory playData = _play_and_get_data(1024+2);
        (/*uint index*/,uint rand,/*uint currentLevelHash*/,uint leavesCount,bytes32[] memory leaves) = _get_leaves(playData.mimcR,playData.mimcC);
        assertGt(leavesCount,0);
        
        bytes32[] memory selectedLeaves = new bytes32[](leavesCount);
        for(uint i = 0; i < leavesCount; i++) {
            selectedLeaves[i] = leaves[i];
        }
        _collect(playData.secret, playData.mask, rand, selectedLeaves);
    }

    function test_lottery_many_deposits() public {
        //bytes32[] memory leaves = new bytes32[](200);
        // 1. Make many deposits with random commitments -- this will let us test with a non-empty merkle tree
        for (uint256 i = 0; i < 100; i++) {
            //leaves[i] = 
            _fake_play_and_get_leaf(i);
        }
        _commit_reveal();

        // 2. Generate commitment and deposit.
        PlayData memory playData = _play_and_get_data(3);
        //leaves[100] = leaf;
        // 3. Make more deposits.
        for (uint256 i = 101; i < 200; i++) {
            //leaves[i] = 
            _fake_play_and_get_leaf(i);
        }
        _commit_reveal();

        (/*uint index*/,uint rand,/*uint currentLevelHash*/,uint leavesCount,bytes32[] memory leaves) = _get_leaves(playData.mimcR,playData.mimcC);
        assertGt(leavesCount,0);
        bytes32[] memory selectedLeaves = new bytes32[](leavesCount);
        for(uint i = 0; i < leavesCount; i++) {
            selectedLeaves[i] = leaves[i];
        }
        _collect(playData.secret,playData.mask,playData.rand,selectedLeaves);
    }
}
