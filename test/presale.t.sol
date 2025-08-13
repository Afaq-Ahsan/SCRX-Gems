// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.25;

import { Test, console } from "../lib/forge-std/src/Test.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { ILockup, ISubscription, IPreSale } from "../contracts/ILockup.sol";

import "../contracts/Common.sol";

import { AggregatorV3Interface, TokenRegistry } from "../contracts/TokenRegistry.sol";
import { PreSale } from "../contracts/PreSale.sol";
import { Claims } from "../contracts/Claims.sol";
import { Rounds } from "../contracts/Rounds.sol";
import { Lockup } from "../contracts/Lockup.sol";
import { Subscription } from "../contracts/Subscription.sol";

contract PreSaleTest is Test {
    using MessageHashUtils for bytes32;
    using SafeERC20 for IERC20;

    error OwnableUnauthorizedAccount(address);

    string code = "12345";
    uint32 round = 2;
    uint256 minAmount = 1;

    uint256 roundPrice = 1000000000000000000;

    IERC20 USDT;
    IERC20 USDC;
    IERC20 GEMS;

    address[] leaders;
    uint256[] percentages;

    uint256 privateKey;
    address signer;
    PreSale public preSale;
    address caller;
    PreSale.TokenInfo ethInfo;
    PreSale.TokenInfo usdtInfo;
    address[] fundsWalletAddresses;
    address signerAddress;
    Claims public claimsContractAddress;
    Lockup public lockupContractAddress;
    Subscription public subscriptionContractAddress;
    address owner;
    address user;
    address usdtWallet;
    address usdcWallet;
    uint32 lastRound;

    function setUp() public {
        USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        GEMS = IERC20(0x3010ccb5419F1EF26D40a7cd3F0d707a0fa127Dc);

        fundsWalletAddresses = [
            0x19A865ab3A6E9DD7ac716891B0080b2cB3ffb9fa,
            0x395bFD879A3AE7eC4E469e26c8C1d7BB2F9d77B9,
            0xF14aEB1Cb06c674B58D87D2Cc2dfc4b1e9f4EdB6
        ];

        leaders = [
            0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269,
            0x19A865ab3A6E9DD7ac716891B0080b2cB3ffb9fa,
            0x395bFD879A3AE7eC4E469e26c8C1d7BB2F9d77B9,
            0xF14aEB1Cb06c674B58D87D2Cc2dfc4b1e9f4EdB6,
            0xC0FC8954c62A45c3c0a13813Bd2A10d88D70750D
        ];

        percentages = [25000, 25000, 25000, 25000, 25000];

        signerAddress = 0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269;
        owner = 0x19A865ab3A6E9DD7ac716891B0080b2cB3ffb9fa;
        user = 0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269;

        privateKey = vm.envUint("PRIVATE_KEY");
        signer = vm.addr(privateKey);
        caller = 0x19A865ab3A6E9DD7ac716891B0080b2cB3ffb9fa;
        usdtWallet = 0xe1E13A8D3d5B1596dc8849aE35c9f410A4aB49D1;
        usdcWallet = 0x5414d89a8bF7E99d732BC52f3e6A3Ef461c0C078;
        deal(caller, 100000000000000000000000e18);
        deal(user, 100000000000000000000000e18);
        deal(address(GEMS), user, 8000000 * 1e18);
        deal(address(USDT), user, 8000000 * 1e6);

        lastRound = 1;

        claimsContractAddress = new Claims(signerAddress, usdtWallet);
        lockupContractAddress = new Lockup(USDT, 1, (block.timestamp + 2 minutes), owner);
        subscriptionContractAddress = new Subscription(owner, user, owner, GEMS, 400000000);
        preSale = new PreSale(
            usdtWallet,
            usdtWallet,
            user,
            signerAddress,
            Claims(claimsContractAddress),
            ILockup(address(lockupContractAddress)),
            ISubscription(address(subscriptionContractAddress)),
            owner,
            lastRound,
            5250000000000000000000000000
        );

        claimsContractAddress.updatePresaleAddress(IPreSale(address(preSale)));

        vm.startPrank(owner);
        preSale.createNewRound(block.timestamp, block.timestamp + 10 minutes, roundPrice);
        IERC20[] memory tokens = new IERC20[](4);
        tokens[0] = IERC20(ETH);
        tokens[1] = USDT;
        tokens[2] = USDC;
        tokens[3] = GEMS;

        bool[] memory accesses = new bool[](4);
        accesses[0] = true;
        accesses[1] = true;
        accesses[2] = true;
        accesses[3] = true;

        uint256[] memory cPrice = new uint256[](4);
        cPrice[0] = 0;
        cPrice[1] = 0;
        cPrice[2] = 0;
        cPrice[3] = 0;

        preSale.updateAllowedTokens(2, tokens, accesses, cPrice);

        TokenRegistry.PriceFeedData[] memory priceFeedData = new TokenRegistry.PriceFeedData[](2);
        priceFeedData[0] = TokenRegistry.PriceFeedData({
            priceFeed: AggregatorV3Interface(0x3E7d1eAB13ad0104d2750B8863b489D65364e32D),
            normalizationFactorForToken: 22,
            tolerance: 172800
        });
        priceFeedData[1] = TokenRegistry.PriceFeedData({
            priceFeed: AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419),
            normalizationFactorForToken: 10,
            tolerance: 7200
        });

        IERC20[] memory tok = new IERC20[](2);
        tok[0] = IERC20(USDT);
        tok[1] = IERC20(ETH);

        preSale.setTokenPriceFeed(tok, priceFeedData);

        usdtInfo = preSale.getLatestPrice(USDT);
        ethInfo = preSale.getLatestPrice(IERC20(ETH));

        vm.stopPrank();

        vm.startPrank(usdtWallet);
        USDT.safeTransfer(user, USDT.balanceOf(usdtWallet));
        vm.stopPrank();

        vm.startPrank(user);
        USDT.forceApprove(address(this), USDT.balanceOf(user));
        vm.stopPrank();

        vm.startPrank(usdcWallet);
        USDC.safeTransfer(user, USDC.balanceOf(usdcWallet));
        vm.stopPrank();

        vm.startPrank(user);
        USDC.forceApprove(address(this), USDC.balanceOf(user));
        vm.stopPrank();
    }

    function testPurchaseTokenWithETH() public {
        uint256 expectedProjectFunds;
        uint256 expectedPlatformfunds;
        uint256 expectedBurnFunds;
        uint256 expectedClaimsFunds;
        uint256 expectedPendingClaims;
        uint256 expectedTotalPercentage = 0;

        uint256 leaderPercentageAmount = (percentages[0]) +
            (percentages[1]) +
            (percentages[2]) +
            (percentages[3]) +
            (percentages[4]);

        uint256[] memory previousLeaderClaims = new uint256[](leaders.length);

        (uint8 v, bytes32 r, bytes32 s) = _signWithETH();
        uint256 deadline = block.timestamp + 2 minutes;

        uint256 investment = 0.105 ether;

        vm.startPrank(signer);
        (v, r, s) = _signWithETH();
        vm.stopPrank();

        _lockupStake();
        _subscribe();
        console.log("subscribed");
        uint256[] memory indexes = new uint256[](1);
        indexes[0] = 0;

        //leader previous claim
        for (uint256 i = 0; i < leaders.length; ++i) {
            previousLeaderClaims[i] = claimsContractAddress.pendingClaims(leaders[i], round, IERC20(ETH));
        }

        uint256 sumPercentage;
        uint256 remainingPercentageAmount;
        for (uint256 j; j < percentages.length; ++j) {
            sumPercentage += percentages[j];
        }

        expectedClaimsFunds = (investment * 250_000) / PPM;
        uint256 sumPercentageAmount = (investment * sumPercentage) / PPM;

        if (sumPercentage < 250_000) {
            remainingPercentageAmount = expectedClaimsFunds - sumPercentageAmount;
        }
        expectedClaimsFunds -= remainingPercentageAmount;
        expectedPlatformfunds = remainingPercentageAmount;

        expectedProjectFunds = (investment * 630000) / PPM;
        expectedPlatformfunds += (investment * 100000) / PPM;
        expectedBurnFunds += (investment * 20000) / PPM;

        vm.startPrank(user);
        preSale.purchaseTokenWithETH{ value: investment }(
            code,
            round,
            deadline,
            minAmount,
            indexes,
            leaders,
            percentages,
            v,
            r,
            s
        );

        for (uint256 i = 0; i < leaders.length; ++i) {
            expectedPendingClaims = (investment * percentages[i]) / PPM;
            expectedTotalPercentage += percentages[i];
            assertEq(
                claimsContractAddress.pendingClaims(leaders[i], round, IERC20(ETH)) - previousLeaderClaims[i],
                expectedPendingClaims,
                "leader fund amount "
            );
        }
        assertEq(expectedTotalPercentage, leaderPercentageAmount, "leader percentage contract");
    }

    function testPurchaseTokenWithUSDT() public {
        uint256 expectedProjectFunds;
        uint256 expectedPlatformfunds;
        uint256 expectedBurnFunds;
        uint256 expectedClaimsFunds;

        uint256[] memory previousLeaderClaims = new uint256[](leaders.length);

        (uint8 v, bytes32 r, bytes32 s) = _signWithToken();
        uint256 deadline = block.timestamp + 2 minutes;

        uint256 investment = 0.105 ether;

        vm.startPrank(signer);
        (v, r, s) = _signWithToken();
        vm.stopPrank();

        _lockupStake();
        _subscribe();
        uint256[] memory indexes = new uint256[](1);
        indexes[0] = 0;

        //leader previous claim
        for (uint256 i = 0; i < leaders.length; ++i) {
            previousLeaderClaims[i] = claimsContractAddress.pendingClaims(leaders[i], round, IERC20(USDT));
        }

        uint256 sumPercentage;
        uint256 remainingPercentageAmount;
        for (uint256 j; j < percentages.length; ++j) {
            sumPercentage += percentages[j];
        }

        expectedClaimsFunds = (investment * 250_000) / PPM;
        uint256 sumPercentageAmount = (investment * sumPercentage) / PPM;

        if (sumPercentage < 250_000) {
            remainingPercentageAmount = expectedClaimsFunds - sumPercentageAmount;
        }
        expectedClaimsFunds -= remainingPercentageAmount;
        expectedPlatformfunds = remainingPercentageAmount;

        expectedProjectFunds = (investment * 630000) / PPM;
        expectedPlatformfunds += (investment * 100000) / PPM;
        expectedBurnFunds += (investment * 20000) / PPM;

        vm.startPrank(user);
        USDT.forceApprove(address(preSale), USDT.balanceOf(user));
        preSale.purchaseTokenWithToken(
            USDT,
            0,
            0,
            100000000,
            minAmount,
            indexes,
            leaders,
            percentages,
            code,
            round,
            deadline,
            v,
            r,
            s
        );
        vm.stopPrank();

        vm.warp(block.timestamp + 100 days);
        claimsContractAddress.grantRole(claimsContractAddress.COMMISSIONS_MANAGER(), address(this));
        claimsContractAddress.enableClaims(2, true);

        IERC20[] memory tokens = new IERC20[](1);
        tokens[0] = USDT;

        vm.startPrank(0x19A865ab3A6E9DD7ac716891B0080b2cB3ffb9fa);
        claimsContractAddress.claim(2, tokens);
        vm.stopPrank();
    }

    function _signWithETH() internal view returns (uint8, bytes32, bytes32) {
        uint256 deadline = block.timestamp + 2 minutes;
        bytes32 mhash = keccak256(abi.encodePacked(user, code, deadline));
        bytes32 msgHash = mhash.toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        return (v, r, s);
    }

    function _signWithToken() internal view returns (uint8, bytes32, bytes32) {
        uint256 referenceTokenPrice = 0;
        uint256 normalizationFactor = 0;
        uint256 deadline = block.timestamp + 2 minutes;
        bytes32 mhash = keccak256(
            abi.encodePacked(user, code, referenceTokenPrice, deadline, USDT, normalizationFactor)
        );
        bytes32 msgHash = mhash.toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        return (v, r, s);
    }

    function _validateSignWithTokenForSubscription(
        uint256 referenceTokenPrice,
        uint256 normalizationFactor,
        IERC20 token,
        uint256 deadline
     ) private returns (uint8, bytes32, bytes32) {
        vm.startPrank(signer);
        bytes32 msgHash = (
            keccak256(abi.encodePacked(user, uint8(normalizationFactor), uint256(referenceTokenPrice), deadline, token))
        ).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, msgHash);
        vm.stopPrank();
        return (v, r, s);
    }

    function _lockupStake() private {
        vm.startPrank(user);
        USDT.forceApprove(address(lockupContractAddress), USDT.balanceOf(user));
        lockupContractAddress.stake(5555);
        vm.stopPrank();
    }

    function _subscribe() private {
        uint256 price = 392522046;
        uint8 nf = 22;

        vm.startPrank(user);
        GEMS.forceApprove(address(subscriptionContractAddress), GEMS.balanceOf(user));

        (uint8 v1, bytes32 r1, bytes32 s1) = _validateSignWithTokenForSubscription(price, nf, GEMS, block.timestamp);
        vm.startPrank(user);

        subscriptionContractAddress.subscribe(price, block.timestamp, nf, v1, r1, s1);
        vm.stopPrank();
    }
}
