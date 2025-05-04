pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";

interface IHasher {
  function MiMCSponge(uint256 in_xL, uint256 in_xR, uint256 k) external pure returns (uint256 xL, uint256 xR);
}

/**
 * @title mimc test
 */
contract mimcTest {
    IHasher public immutable hasher;

    constructor(IHasher _Hasher) {
        hasher = _Hasher;
    }

    function MiMCSponge(uint256 in_xL, uint256 in_xR, uint256 k) public view returns (uint256 xL, uint256 xR) {
        return hasher.MiMCSponge(in_xL, in_xR, k);
    }
}
