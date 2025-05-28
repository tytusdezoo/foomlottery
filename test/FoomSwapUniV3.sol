// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// import "forge-std/Test.sol";
import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

interface IWETH is IERC20 {
    function deposit() external payable;
}

interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);
}

contract UniswapV3SwapTest is Test {
    ISwapRouter public constant swapRouter =
        ISwapRouter(0x2626664c2603336E57B271c5C0b26F421741e481);

    address public constant WETH = 0x4200000000000000000000000000000000000006;
    address public constant FOOM_BASE = 0x02300aC24838570012027E0A90D3FEcCEF3c51d2;
    //dai   0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb; 

    IWETH public weth = IWETH(WETH);
    IERC20 public foom_base = IERC20(FOOM_BASE);

    function setUp() public {
        console.log("Forking Base...");
        vm.createSelectFork("base");

        vm.deal(address(this), 10 ether);

        console.log("ETH balance of address this:", address(this).balance);
    }

    function test() public {
        vm.deal(address(this), 10 ether);

        (bool success, ) = address(this).call{value: 0.015 ether}(
            abi.encodeWithSignature("swapEthForFoom()")
        );
        require(success, "External call to test() failed");
    }

    function swapEthForFoom() public payable {
        require(address(this).balance >= 0.015 ether, "Not enough ETH");
        swapFoom();
    }

    function swapFoom() public payable {
        require(msg.value > 0, "ETH required");

        uint256 amountIn = msg.value;

        // Wrap ETH to WETH
        weth.deposit{value: amountIn}();

        // Approve Uniswap V3 router to spend WETH
        weth.approve(address(swapRouter), amountIn);

        console.log("WETH balance before swap:", weth.balanceOf(address(this)));

        // Prepare swap parameters
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: WETH,
                tokenOut: FOOM_BASE,
                fee: 3000, //100 for dai
                recipient: address(this), 
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // Perform the swap
        uint256 amountOut = swapRouter.exactInputSingle(params);

        console.log("Swapped WETH:", amountIn);
        console.log("Received FOOM_BASE:", amountOut);
        console.log("FOOM balance:", foom_base.balanceOf(address(this)));

        assertTrue(foom_base.balanceOf(address(this)) > 0);
    }
}

/* EXAMPLE LOGS 
[⠊] Compiling...
[⠊] Compiling 1 files with Solc 0.8.29
[⠒] Solc 0.8.29 finished in 897.24ms
Compiler run successful!

Ran 1 test for test/FoomSwapUniV3.sol:UniswapV3SwapTest
[PASS] test() (gas: 151951)
Logs:
  Forking Base...
  ETH balance of address this: 10000000000000000000
  WETH balance before swap: 15000000000000000
  Swapped WETH: 15000000000000000
  Received FOOM_BASE: 377558830159294998129142237
  FOOM balance: 377558830159294998129142237

Traces:
  [191751] UniswapV3SwapTest::test()
    ├─ [0] VM::deal(UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], 10000000000000000000 [1e19])
    │   └─ ← [Return]
    ├─ [178922] UniswapV3SwapTest::swapEthForFoom{value: 15000000000000000}()
    │   ├─ [23802] 0x4200000000000000000000000000000000000006::deposit{value: 15000000000000000}()
    │   │   ├─ emit Deposit(param0: UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], param1: 15000000000000000 [1.5e16])
    │   │   └─ ← [Stop]
    │   ├─ [24399] 0x4200000000000000000000000000000000000006::approve(0x2626664c2603336E57B271c5C0b26F421741e481, 15000000000000000 [1.5e16])
    │   │   ├─ emit Approval(owner: UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], spender: 0x2626664c2603336E57B271c5C0b26F421741e481, value: 15000000000000000 [1.5e16])
    │   │   └─ ← [Return] true
    │   ├─ [457] 0x4200000000000000000000000000000000000006::balanceOf(UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]) [staticcall]
    │   │   └─ ← [Return] 15000000000000000 [1.5e16]
    │   ├─ [0] console::log("WETH balance before swap:", 15000000000000000 [1.5e16]) [staticcall]
    │   │   └─ ← [Stop]
    │   ├─ [91789] 0x2626664c2603336E57B271c5C0b26F421741e481::exactInputSingle(ExactInputSingleParams({ tokenIn: 0x4200000000000000000000000000000000000006, tokenOut: 0x02300aC24838570012027E0A90D3FEcCEF3c51d2, fee: 3000, recipient: 0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496, amountIn: 15000000000000000 [1.5e16], amountOutMinimum: 0, sqrtPriceLimitX96: 0 }))
    │   │   ├─ [84364] 0xc5adb6F67c54D187a9FD8bA4994855e35963B69D::swap(UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], false, 15000000000000000 [1.5e16], 1461446703485210103287273052203988822378723970341 [1.461e48], 0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000400000000000000000000000007fa9385be102ac3eac297483dd6233d62b3e1496000000000000000000000000000000000000000000000000000000000000002b4200000000000000000000000000000000000006000bb802300ac24838570012027e0a90d3feccef3c51d2000000000000000000000000000000000000000000)
    │   │   │   ├─ [29794] 0x02300aC24838570012027E0A90D3FEcCEF3c51d2::transfer(UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], 377558830159294998129142237 [3.775e26])
    │   │   │   │   ├─ emit Transfer(from: 0xc5adb6F67c54D187a9FD8bA4994855e35963B69D, to: UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], value: 377558830159294998129142237 [3.775e26])
    │   │   │   │   └─ ← [Return] true
    │   │   │   ├─ [2457] 0x4200000000000000000000000000000000000006::balanceOf(0xc5adb6F67c54D187a9FD8bA4994855e35963B69D) [staticcall]
    │   │   │   │   └─ ← [Return] 124303122809367388 [1.243e17]
    │   │   │   ├─ [10823] 0x2626664c2603336E57B271c5C0b26F421741e481::uniswapV3SwapCallback(-377558830159294998129142237 [-3.775e26], 15000000000000000 [1.5e16], 0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000400000000000000000000000007fa9385be102ac3eac297483dd6233d62b3e1496000000000000000000000000000000000000000000000000000000000000002b4200000000000000000000000000000000000006000bb802300ac24838570012027e0a90d3feccef3c51d2000000000000000000000000000000000000000000)
    │   │   │   │   ├─ [6700] 0x4200000000000000000000000000000000000006::transferFrom(UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], 0xc5adb6F67c54D187a9FD8bA4994855e35963B69D, 15000000000000000 [1.5e16])
    │   │   │   │   │   ├─ emit Transfer(from: UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], to: 0xc5adb6F67c54D187a9FD8bA4994855e35963B69D, value: 15000000000000000 [1.5e16])
    │   │   │   │   │   └─ ← [Return] true
    │   │   │   │   └─ ← [Stop]
    │   │   │   ├─ [457] 0x4200000000000000000000000000000000000006::balanceOf(0xc5adb6F67c54D187a9FD8bA4994855e35963B69D) [staticcall]
    │   │   │   │   └─ ← [Return] 139303122809367388 [1.393e17]
    │   │   │   ├─ emit Swap(param0: 0x2626664c2603336E57B271c5C0b26F421741e481, param1: UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496], param2: -377558830159294998129142237 [-3.775e26], param3: 15000000000000000 [1.5e16], param4: 499516919069187526806162 [4.995e23], param5: 670352663035378600815122 [6.703e23], param6: -239496 [-2.394e5])
    │   │   │   └─ ← [Return] 0xfffffffffffffffffffffffffffffffffffffffffec7b0cece152854fe0c162300000000000000000000000000000000000000000000000000354a6ba7a18000
    │   │   └─ ← [Return] 377558830159294998129142237 [3.775e26]
    │   ├─ [0] console::log("Swapped WETH:", 15000000000000000 [1.5e16]) [staticcall]
    │   │   └─ ← [Stop]
    │   ├─ [0] console::log("Received FOOM_BASE:", 377558830159294998129142237 [3.775e26]) [staticcall]
    │   │   └─ ← [Stop]
    │   ├─ [563] 0x02300aC24838570012027E0A90D3FEcCEF3c51d2::balanceOf(UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]) [staticcall]
    │   │   └─ ← [Return] 377558830159294998129142237 [3.775e26]
    │   ├─ [0] console::log("FOOM balance:", 377558830159294998129142237 [3.775e26]) [staticcall]
    │   │   └─ ← [Stop]
    │   ├─ [563] 0x02300aC24838570012027E0A90D3FEcCEF3c51d2::balanceOf(UniswapV3SwapTest: [0x7FA9385bE102ac3EAc297483Dd6233D62b3e1496]) [staticcall]
    │   │   └─ ← [Return] 377558830159294998129142237 [3.775e26]
    │   ├─ [0] VM::assertTrue(true) [staticcall]
    │   │   └─ ← [Return]
    │   └─ ← [Return]
    └─ ← [Return]

Suite result: ok. 1 passed; 0 failed; 0 skipped; finished in 6.05s (2.63s CPU time)

Ran 1 test suite in 6.84s (6.05s CPU time): 1 tests passed, 0 failed, 0 skipped (1 total tests)


*/
