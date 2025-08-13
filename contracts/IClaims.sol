// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @member token The token address
/// @member amount The token amount
struct ClaimInfo {
    IERC20 token;
    uint256 amount;
}

interface IClaims {
    /// @notice Sets claim token and amount in the given round
    /// @param to The address of the leader
    /// @param claims The claim token and amount of the leader
    function addClaimInfo(address[] calldata to, uint32 round, ClaimInfo[] calldata claims) external;
}
