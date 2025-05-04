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

    //function MiMCSponge(bytes32 in_xL, bytes32 in_xR, bytes32 k) public view returns (uint256 xL, uint256 xR) {
    function MiMCSponge(uint in_xL, uint in_xR, uint k) public view returns (uint256 xL, uint256 xR) {
        return hasher.MiMCSponge(uint(in_xL),uint(in_xR),uint(k));
    }
}
