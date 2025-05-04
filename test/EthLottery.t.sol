// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Test, console} from "forge-std/Test.sol";
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
        lottery = new EthLottery(withdraw, cancel, IHasher(mimcHasher), IERC20(address(0)), betMin);
    }

    function _getWitnessAndProof(
        uint _secret,
        uint _mask,
        uint _rand,
        address _recipient,
        address _relayer,
        bytes32[] memory leaves
    ) internal returns (uint256[2] memory, uint256[2][2] memory, uint256[2] memory, uint, uint, uint, uint, uint) {
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
        (uint256[2] memory pA, uint256[2][2] memory pB, uint256[2] memory pC, uint root, uint nullifierHash, uint rew1, uint rew2, uint rew3) =
            abi.decode(result, (uint256[2], uint256[2][2], uint256[2], uint, uint, uint, uint, uint));

        return (pA, pB, pC, root, nullifierHash, rew1, rew2, rew3);
    }

    function _getCommitment() internal returns (uint commitment, uint secret) {
        string[] memory inputs = new string[](2);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/generateCommitment.js";

        bytes memory result = vm.ffi(inputs);
        (commitment, secret) = abi.decode(result, (uint, uint));
	//console.log("%x commmitment\n",commitment);
	//console.log("%x secret\n",secret);

        return (commitment, secret);
    }

    function _play_and_get_data() internal returns (uint,uint,uint,uint,uint,bytes32) {
        uint _amount=3;
        // 1. Generate commitment and deposit
        (uint commitment, uint secret) = _getCommitment();
        (uint mask) = lottery.getMask(_amount*betMin);
        lottery.play{value: _amount*betMin}(commitment,0);
	// 1.5. Process bets by admin
        (uint betsIndex, uint commitCount, uint commitBlock,uint commitHash)=lottery.getStatus();
        assertEq(commitBlock,0);
        uint _revealSecret = uint(keccak256(abi.encodePacked(commitCount)));
        uint _commitHash = uint(keccak256(abi.encodePacked(_revealSecret)));
        lottery.commit(_commitHash);
        vm.roll(++blocknumber);
	//console.log("block: %d\n",block.number);
	/* must wait for the transaction to get included in a block */
        uint commitCountNew;
        (betsIndex, commitCountNew, commitBlock,commitHash)=lottery.getStatus();
        assertGt(commitBlock,0);
        assertEq(commitHash,_commitHash);
        assertEq(commitCount+1,commitCountNew);
        (uint rand,uint leaf)=lottery.reveal(_revealSecret);
	//console.log("%x shas\n",commitment);
	//console.log("%x mask\n",mask);
	//console.log("%x rand\n",rand);
	//console.log("%x leaf\n",leaf);


        vm.roll(++blocknumber);
	//console.log("block: %d\n",block.number);
        (betsIndex, commitCount, commitBlock,commitHash)=lottery.getStatus();
        assertEq(commitBlock,0);
        return(_amount,commitment,secret,mask,rand,bytes32(leaf));
    }

    function _collect(uint secret,uint mask,uint rand,bytes32[] memory leaves) internal {
	//console.log("%x secret\n",secret);
        (uint256[2] memory pA, uint256[2][2] memory pB, uint256[2] memory pC, uint root, uint nullifierHash, uint rew1, uint rew2, uint rew3) =
            _getWitnessAndProof(secret, mask, rand, recipient, relayer, leaves);
	//console.log("now: %d\n",block.number);
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

    function _fake_play_and_get_leaf(uint i) internal returns (bytes32) {
        uint _amount=3;
        uint commitment = uint(uint256(keccak256(abi.encode(i))) % FIELD_SIZE);
        lottery.play{value: _amount*betMin}(commitment,0);
        // 1.5. Process bets by admin
        //(uint betsIndex, uint commitCount, uint commitBlock,uint commitHash)=lottery.getStatus();
        (,uint commitCount,,)=lottery.getStatus();
        uint _revealSecret = uint(keccak256(abi.encodePacked(commitCount)));
        uint _commitHash = uint(keccak256(abi.encodePacked(_revealSecret)));
        lottery.commit(_commitHash);
        //(uint rand,uint leaf)=lottery.reveal(_revealSecret);
        (,uint leaf)=lottery.reveal(_revealSecret);
        return(bytes32(leaf));
    }

    function test_mimc() public {
        uint inL=1;
        uint inR=2;
        uint k=3;
        (uint oL,uint oR)=lottery.MiMCSponge(inL,inR,k);
        console.log("%x R",oL);
        console.log("%x C",oR);
    }

    function _notest_lottery_single_deposit() public {
        uint max=21888242871839275222246405745257275088548364400416034343698204186575808495617;
	//console.log("%x max\n",max);
        //(uint _amount,uint commitment,uint secret,uint mask,uint rand,bytes32 leaf) = _play_and_get_data();
        (,,uint secret,uint mask,uint rand,bytes32 leaf) = _play_and_get_data();
        bytes32[] memory leaves = new bytes32[](1);
        leaves[0] = leaf;
        _collect(secret,mask,rand,leaves);
    }

    function _notest_lottery_many_deposits() public {
        bytes32[] memory leaves = new bytes32[](200);
        // 1. Make many deposits with random commitments -- this will let us test with a non-empty merkle tree
        for (uint256 i = 0; i < 100; i++) {
            leaves[i] = _fake_play_and_get_leaf(i);
        }
        // 2. Generate commitment and deposit.
        //(uint _amount,uint commitment,uint secret,uint mask,uint rand,bytes32 leaf) = _play_and_get_data();
        (,,uint secret,uint mask,uint rand,bytes32 leaf) = _play_and_get_data();
        leaves[100] = leaf;
        // 3. Make more deposits.
        for (uint256 i = 101; i < 200; i++) {
            leaves[i] = _fake_play_and_get_leaf(i);
        }
        _collect(secret,mask,rand,leaves);
    }
}
