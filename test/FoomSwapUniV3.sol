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
        uint256 deadline;
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
        ISwapRouter(0x6fF5693b99212Da76ad316178A184AB56D299b43); 

    address public constant WETH = 0x4200000000000000000000000000000000000006;
    address public constant FOOM_BASE =
        0x02300aC24838570012027E0A90D3FEcCEF3c51d2;

    IWETH public weth = IWETH(WETH);
    IERC20 public foom_base = IERC20(FOOM_BASE);

    function setUp() public {
        console.log("Forking Base...");
        vm.createSelectFork("base");

        // Upewnij się, że adres testowy ma ETH — można też skopiować z bogatego adresu
        vm.deal(address(this), 10 ether);

        console.log("ETH balance of address this:", address(this).balance);
    }

    function test() public payable {
        require(address(this).balance >= 1 ether, "Not enough ETH");
        swapFoom(0.1 ether);
    }

    function swapFoom(uint256 amountIn) public payable {
        require(amountIn > 0, "ETH required");

        // Wrap ETH to WETH
        weth.deposit{value: amountIn}();

        // Approve Uniswap V3 router to spend WETH
        weth.approve(address(swapRouter), amountIn);

        console.log("WETH balance:", weth.balanceOf(address(this)));

        // Prepare swap parameters
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: WETH,
                tokenOut: FOOM_BASE,
                fee: 3000,
                recipient: address(this),
                deadline: block.timestamp + 1 hours,
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
