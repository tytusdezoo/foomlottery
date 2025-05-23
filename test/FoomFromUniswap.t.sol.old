// test/BalanceChecker.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "src/FoomSwapper.sol";

// @dev to run test type:
// forge test --via-ir --match-path test/FoomFromUniswap.t.sol -vv

contract BalanceCheckerTest is Test {
    address target = 0x8CFd3E12F499fceEff08381155B243c20F83F551;
    address private WETH_ADDRESS = address(0x4200000000000000000000000000000000000006);
    address private ROUTER_ADDRESS = address(0x2626664c2603336E57B271c5C0b26F421741e481);
    ISwapRouter private router;

    address user = address(1);
    FoomSwapper public swapper;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("base"));
        swapper = new FoomSwapper();
        vm.deal(user, 10 ether);
        router = ISwapRouter(ROUTER_ADDRESS);
    }

    function testGetBalance() public view {
        uint256 balance = target.balance;
        console2.log("Balance of target:", balance);
        assert(balance > 0);
        uint256 testUserBalance = user.balance;
        console2.log("Balance of TEST USER:", testUserBalance);
        assert(testUserBalance > 0);
    }

    function testSwapEthForFoomUniswapV2() public {
        uint256 amountToSwap = 0.01 ether;
        vm.prank(user);
        (bool success, bytes memory data) = address(swapper).call{
            value: amountToSwap
        }(abi.encodeWithSignature("swapEthForFoomUniswapV2()"));
        if (!success) {
            console2.log("Swap reverted with reason:");
            if (data.length >= 68) {
                assembly {
                    data := add(data, 0x04)
                }
                string memory reason = abi.decode(data, (string));
                console2.log(reason);
            } else {
                console2.log("No revert string.");
            }
            fail();
        }
        uint256 foomReceived = abi.decode(data, (uint256));
        console2.log("FOOM received:", foomReceived);
        assertGt(foomReceived, 0, "Should receive some FOOM tokens");
    }
}
