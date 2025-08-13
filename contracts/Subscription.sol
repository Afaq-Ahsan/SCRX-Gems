// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import { SafeERC20, IERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { ReentrancyGuardTransient } from "@openzeppelin/contracts/utils/ReentrancyGuardTransient.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";

/// @title Subscription contract
/// @notice Implements the functionality of purchasing premium subscription
/// @notice The subscription contract allows you to get premium subscription using GEMS.
contract Subscription is Ownable2Step, ReentrancyGuardTransient {
    using SafeERC20 for IERC20;

    /// @dev The constant value helps in calculating subscription time for each index
    uint256 private constant SUBSCRIPTION_TIME = 31536000;

    /// @notice The address of the GEMS token
    IERC20 public immutable GEMS;

    /// @notice The subscription fee in USD
    uint256 public subscriptionFee;

    /// @notice The address of the signer wallet
    address public signerWallet;

    /// @notice The address of the funds wallet
    address public fundsWallet;

    /// @notice That buyEnabled or not
    bool public buyEnabled = true;

    /// @notice Gives info about address's permission
    mapping(address => bool) public blacklistAddress;

    /// @notice Stores the end time of the user's subscription
    mapping(address => uint256) public subEndTimes;

    /// @dev Emitted when address of signer is updated
    event SignerUpdated(address oldSigner, address newSigner);

    /// @dev Emitted when address of funds wallet is updated
    event FundsWalletUpdated(address oldfundsWallet, address newfundsWallet);

    /// @dev Emitted when blacklist access of address is updated
    event BlacklistUpdated(address which, bool accessNow);

    /// @dev Emitted when buying access changes
    event BuyEnableUpdated(bool oldAccess, bool newAccess);

    /// @dev Emitted when subscription fee is updated
    event SubscriptionFeeUpdated(uint256 oldFee, uint256 newFee);

    /// @dev Emitted when subscription is purchased
    event Subscribed(uint256 tokenPrice, address indexed by, uint256 amountPurchased, uint256 indexed endTime);

    /// @notice Thrown when address is blacklisted
    error Blacklisted();

    /// @notice Thrown when buy is disabled
    error BuyNotEnabled();

    /// @notice Thrown when sign deadline is expired
    error DeadlineExpired();

    /// @notice Thrown when value is zero
    error ZeroValue();

    /// @notice Thrown when updating with the same value as previously stored
    error IdenticalValue();

    /// @notice Thrown when an address is zero address
    error ZeroAddress();

    /// @notice Thrown when sign is invalid
    error InvalidSignature();

    /// @notice Thrown when user have already have subscription
    error AlreadySubscribed();

    /// @dev Restricts when updating wallet/contract address with zero address
    modifier checkAddressZero(address which) {
        _checkAddressZero(which);
        _;
    }

    /// @dev Constructor
    /// @param fundsWalletAddress The address of funds wallet
    /// @param signerAddress The address of signer wallet
    /// @param owner The address of owner wallet
    /// @param gemsAddress The address of gems contract
    /// @param subscriptionFeeInit The subscription fee in USD
    constructor(
        address fundsWalletAddress,
        address signerAddress,
        address owner,
        IERC20 gemsAddress,
        uint256 subscriptionFeeInit
    )
        Ownable(owner)
        checkAddressZero(fundsWalletAddress)
        checkAddressZero(signerAddress)
        checkAddressZero(address(gemsAddress))
    {
        if (subscriptionFeeInit == 0) {
            revert ZeroValue();
        }

        fundsWallet = fundsWalletAddress;
        signerWallet = signerAddress;
        GEMS = gemsAddress;
        subscriptionFee = subscriptionFeeInit;
    }

    /// @notice Purchases the premium subscription with GEMS
    /// @param referenceTokenPrice The current price of GEMS in 10 decimals
    /// @param deadline The deadline is validity of the signature
    /// @param referenceNormalizationFactor The normalization factor
    /// @param v The `v` signature parameter
    /// @param r The `r` signature parameter
    /// @param s The `s` signature parameter
    function subscribe(
        uint256 referenceTokenPrice,
        uint256 deadline,
        uint8 referenceNormalizationFactor,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        if (!buyEnabled) {
            revert BuyNotEnabled();
        }

        if (blacklistAddress[msg.sender]) {
            revert Blacklisted();
        }

        if (block.timestamp > deadline) {
            revert DeadlineExpired();
        }

        if (subEndTimes[msg.sender] > block.timestamp) {
            revert AlreadySubscribed();
        }

        if (referenceTokenPrice == 0 || referenceNormalizationFactor == 0) {
            revert ZeroValue();
        }

        // The input must have been signed by the presale signer
        bytes32 encodedMessageHash = keccak256(
            abi.encodePacked(msg.sender, referenceNormalizationFactor, referenceTokenPrice, deadline, GEMS)
        );

        if (signerWallet != ECDSA.recover(MessageHashUtils.toEthSignedMessageHash(encodedMessageHash), v, r, s)) {
            revert InvalidSignature();
        }

        uint256 purchaseAmount = (subscriptionFee * (10 ** referenceNormalizationFactor)) / referenceTokenPrice;

        if (purchaseAmount == 0) {
            revert ZeroValue();
        }

        GEMS.safeTransferFrom(msg.sender, fundsWallet, purchaseAmount);
        subEndTimes[msg.sender] = block.timestamp + SUBSCRIPTION_TIME;

        emit Subscribed({
            tokenPrice: referenceTokenPrice,
            by: msg.sender,
            amountPurchased: purchaseAmount,
            endTime: subEndTimes[msg.sender]
        });
    }

    /// @notice Changes access of buying
    /// @param enabled The decision about buying
    function enableBuy(bool enabled) external onlyOwner {
        if (buyEnabled == enabled) {
            revert IdenticalValue();
        }

        emit BuyEnableUpdated({ oldAccess: buyEnabled, newAccess: enabled });

        buyEnabled = enabled;
    }

    /// @notice Changes signer wallet address
    /// @param newSigner The address of the new signer wallet
    function changeSigner(address newSigner) external checkAddressZero(newSigner) onlyOwner {
        address oldSigner = signerWallet;

        if (oldSigner == newSigner) {
            revert IdenticalValue();
        }

        emit SignerUpdated({ oldSigner: oldSigner, newSigner: newSigner });

        signerWallet = newSigner;
    }

    /// @notice Changes funds wallet address
    /// @param newfundsWallet The address of the new funds wallet
    function updatefundsWallet(address newfundsWallet) external checkAddressZero(newfundsWallet) onlyOwner {
        address oldfundsWallet = fundsWallet;

        if (oldfundsWallet == newfundsWallet) {
            revert IdenticalValue();
        }

        emit FundsWalletUpdated({ oldfundsWallet: oldfundsWallet, newfundsWallet: newfundsWallet });

        fundsWallet = newfundsWallet;
    }

    /// @notice Changes the subscription fee
    /// @param newFee The new subscription fee
    function updateSubscriptionFee(uint256 newFee) external onlyOwner {
        uint256 oldFee = subscriptionFee;

        if (newFee == oldFee) {
            revert IdenticalValue();
        }

        if (newFee == 0) {
            revert ZeroValue();
        }

        emit SubscriptionFeeUpdated({ oldFee: oldFee, newFee: newFee });

        subscriptionFee = newFee;
    }

    /// @notice Changes the access of any address in contract interaction
    /// @param which The address for which access is updated
    /// @param access The access decision of `which` address
    function updateBlackListedUser(address which, bool access) external checkAddressZero(which) onlyOwner {
        bool oldAccess = blacklistAddress[which];

        if (oldAccess == access) {
            revert IdenticalValue();
        }

        emit BlacklistUpdated({ which: which, accessNow: access });

        blacklistAddress[which] = access;
    }

    /// @dev Checks zero address, if zero then reverts
    /// @param which The `which` address to check for zero address
    function _checkAddressZero(address which) private pure {
        if (which == address(0)) {
            revert ZeroAddress();
        }
    }
}
