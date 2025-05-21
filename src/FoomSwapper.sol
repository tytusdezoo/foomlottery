// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
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

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(
        ExactInputParams calldata params
    ) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(
        ExactOutputSingleParams calldata params
    ) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactOutput(
        ExactOutputParams calldata params
    ) external payable returns (uint256 amountIn);
}

interface IWETH is IERC20 {
    function deposit() external payable;
}

interface IUniswapV2Router02 {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract FoomSwapper {
     address private constant WETH_ADDRESS = 0x4200000000000000000000000000000000000006;
    address private constant ROUTER_ADDRESS = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24; // Uniswap V2 Router
    address private constant FOOM_ADDRESS = 0x02300aC24838570012027E0A90D3FEcCEF3c51d2;
    
    IUniswapV2Router02 private router;

    constructor() {
        router = IUniswapV2Router02(ROUTER_ADDRESS);
    }

    receive() external payable {}

    function swapEthForFoomUniswapV2() external payable returns (uint amountOut) {
        require(msg.value > 0, "must have eth");

        IWETH(WETH_ADDRESS).deposit{ value: msg.value }();

        IERC20(WETH_ADDRESS).approve(ROUTER_ADDRESS, msg.value);

        address[] memory path;
        path = new address[](2);
        path[0] = WETH_ADDRESS;
        path[1] = FOOM_ADDRESS;

        // Execute the swap
        uint[] memory amounts = router.swapExactTokensForTokens(
            msg.value,
            0, 
            path,
            msg.sender,
            block.timestamp + 15
        );

        amountOut = amounts[1];

        return amountOut;
    }
}
