// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @dev The address of the Ethereum
IERC20 constant ETH = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

/// @dev The constant value helps in calculating percentages
uint256 constant PPM = 1_000_000;

/// @notice Thrown when updating an address with zero address
error ZeroAddress();

/// @notice Thrown when updating with an array of no values
error ZeroLengthArray();

/// @notice Thrown when updating with the same value as previously stored
error IdenticalValue();

/// @notice Thrown when two array lengths does not match
error ArrayLengthMismatch();

/// @notice Thrown when sign is invalid
error InvalidSignature();

/// @notice Thrown when input array length is zero
error InvalidData();
