// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IRounds } from "./IRounds.sol";

interface ILockup {
    /// @notice Returns locked amount of user at given index
    /// @param user The address of the user
    /// @param index The index number at which user has locked amount
    function stakes(address user, uint256 index) external view returns (uint256 amount, uint256 endTime);

    /// @notice Returns the minimum lockup amount
    function minStakeAmount() external view returns (uint256);
}

interface ISubscription {
    /// @notice Returns subscription end time of user
    /// @param user The address of the user
    function subEndTimes(address user) external view returns (uint256 endTime);
}

interface IPreSale is IRounds {
    /// @notice Purchases token with claim amount
    /// @param token The purchase token
    /// @param tokenPrice The current price of token in 10 decimals
    /// @param referenceNormalizationFactor The value to handle decimals
    /// @param amount The purchase amount
    /// @param minAmountToken The minimum amount of token recipient will get
    /// @param indexes The indexes at which user has locked tokens
    /// @param recipient The address of the recipient
    /// @param round The round in which user will purchase
    function purchaseWithClaim(
        IERC20 token,
        uint256 tokenPrice,
        uint8 referenceNormalizationFactor,
        uint256 amount,
        uint256 minAmountToken,
        uint256[] calldata indexes,
        address recipient,
        uint32 round
    ) external payable;
}

