// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable, Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

import { ZeroAddress, ArrayLengthMismatch, ZeroLengthArray, IdenticalValue } from "./Common.sol";

/// @title Tokens Registry contract
/// @notice Implements the price feed of the tokens
abstract contract TokenRegistry is Ownable2Step {
    /// @member priceFeed The Chainlink price feed address
    /// @member normalizationFactorForToken The normalization factor to achieve return value of 18 decimals, while calculating presale token purchases and always with different token decimals
    /// @member tolerance The pricefeed live price should be updated in tolerance time to get better price
    struct PriceFeedData {
        AggregatorV3Interface priceFeed;
        uint8 normalizationFactorForToken;
        uint256 tolerance;
    }

    /// @notice Gives us onchain price oracle address of the token
    mapping(IERC20 => PriceFeedData) public tokenData;

    /// @dev Emitted when address of Chainlink price feed contract is added for the token
    event TokenDataAdded(IERC20 token, PriceFeedData data);

    /// @notice Sets token price feeds and normalization factors
    /// @param tokens The addresses of the tokens
    /// @param priceFeedData Contains the price feed of the tokens, tolerance and the normalization factor
    function setTokenPriceFeed(IERC20[] calldata tokens, PriceFeedData[] calldata priceFeedData) external onlyOwner {
        uint256 tokensLength = tokens.length;

        if (tokensLength == 0) {
            revert ZeroLengthArray();
        }

        if (tokensLength != priceFeedData.length) {
            revert ArrayLengthMismatch();
        }

        for (uint256 i = 0; i < tokensLength; ++i) {
            PriceFeedData calldata data = priceFeedData[i];
            IERC20 token = tokens[i];
            PriceFeedData memory currentPriceFeedData = tokenData[token];

            if (address(token) == address(0) || address(data.priceFeed) == address(0)) {
                revert ZeroAddress();
            }

            if (
                currentPriceFeedData.priceFeed == data.priceFeed &&
                currentPriceFeedData.normalizationFactorForToken == data.normalizationFactorForToken &&
                currentPriceFeedData.tolerance == data.tolerance
            ) {
                revert IdenticalValue();
            }

            emit TokenDataAdded({ token: token, data: data });
            tokenData[token] = data;
        }
    }
}
