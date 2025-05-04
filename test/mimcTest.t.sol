// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {mimcTest, IHasher } from "src/mimcTest.sol";

contract EthLotteryTest is Test {

    mimcTest public mimctest;

    function setUp() public {
        string[] memory inputs = new string[](3);
        inputs[0] = "node";
        inputs[1] = "forge-ffi-scripts/deployMimcsponge.js";
        bytes memory mimcspongeBytecode = vm.ffi(inputs);
        address mimcHasher;
        assembly {
            mimcHasher := create(0, add(mimcspongeBytecode, 0x20), mload(mimcspongeBytecode))
            if iszero(mimcHasher) { revert(0, 0) }
        }
        mimctest = new mimcTest(IHasher(mimcHasher));
    }

    function test_mimc() public {
        uint inL=1;
        uint inR=0;
        uint k=0;
        console.log("%x inL",inL);
        console.log("%x inR",inR);
        console.log("%x k",k);
        (uint oL,uint oR)=mimctest.MiMCSponge(inL,inR,k);
        console.log("%x oL",oL);
        console.log("%x oR",oR);
    }
}
