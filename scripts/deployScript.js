const hre = require("hardhat");
const { ethers } = require("hardhat");
async function verify(address, constructorArguments) {
  console.log(
    `verify ${address} with arguments ${constructorArguments.join(",")}`
  );
  await run("verify:verify", {
    address,
    constructorArguments,
  });
}
async function main() {
  await hre.run("compile");
  // -------------------------------- blocktimstamp ------------------------------------------ //
  let now = Date.now(); // Unix timestamp in milliseconds
  now = now / 1000;
  now = Math.trunc(now);

  // -------------------------------- Data and Variables------------------------------------------ //
  const data = {
    fundsWalletAddress: "0xDebaDF0D39dD5f1819FE609c4d143610E771236A",
    platformWalletAddress: "0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b",
    signerAddress: "0x22dA5C97F742eC3828a8183896dA56B44eFd0471",
    tokenRegistryAddress: "0x394D002227f0C0E06d4fA991b646A3d5EE34421D",
    lockLiquidityAddress: "0x1791e039FD93914191d392c53AF0e001351f94f5",
    universalRouterAddress: "0x3fC91A3afd70395Cd496C647d5a6CC9D4B2b7FAD",
    quoterAddress: "0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a",
    owner: "0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b",
    presaleTokenContractAddress: "0xBD717eeEDE582c646AaD196846b058DF0b75DBff",
    usdtAddress: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
    positionManagerAddress: "0x03a520b32C04BF3bEEf7BEb72E919cf822Ed34f1",
    permitAddress: "0x000000000022D473030F116dDEE9F6B43aC78BA3",
    factoryV3Address: "0x33128a8fC17869897dcE68Ed026d694621f6FDfD",
    startTimes: [now + 20],
    endTimes: [now + 30],
    prices: [hre.ethers.parseEther("0.01")],
    allowedTokens: [["0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913"]],
    customPrices: [[hre.ethers.parseEther("0")]],
    referralCommissionPPMinit: 100000,
    hardCapAmount: 100000000000,
    minBuyAmount: 10,
    maxBuyAmount: 100000000000,
    sqrtLaunchPrice: 7922816251426433759354n,
    liquidityPercentInit: 100000,
    tokensToSell: "10000000000000000",
    liquidityTokens: "1000000000000",
  };

  const ADMIN_ROLE =
    "0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42";

  const TOKEN_NF_ETH = 10;
  const NFT_NF_ETH = 20;
  const TOLERANCE_ETH = 7200;

  const TOKEN_NF_USDT_USDC = 22;
  const NFT_NF_USDT_USDC = 8;
  const TOLERANCE_USDT_USDC = 172800;

  const ETH = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE";
  const USDC = "0x833589fcd6edb6e08f4c7c32d4f71b54bda02913";
  const WETH = "0x4200000000000000000000000000000000000006";
  const WBTC = "0xcbb7c0000ab88b473b1f5afd9ef808440eed33bf";

  const projectWalletAddress = "0x5d63cE81FAbaCf586A8fd4039Db08B59BE909D5b";
  const platformWalletAddress = "0x0cFA15E360B968E4706050A4FebeB57bdb8C5701";
  const burnWalletAddress = "0xDebaDF0D39dD5f1819FE609c4d143610E771236A";
  const signerAddress = "0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269";
  const owner = "0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269";
  const gemsAddress = "0xb297d4b01b286de35ee12cdce89ec9488eeec0c2";
  const usdtAddress = "0x6fea2f1b82afc40030520a6c49b0d3b652a65915";
  const claimsContractAddress = "0x9B0ff3Df4cE099cE317a792FB947901D2c5169Ac";
  const minerNftContractAddress = "0x9B0ff3Df4cE099cE317a792FB947901D2c5169Ac";
  const nodeNftContractAddress = "0x9B0ff3Df4cE099cE317a792FB947901D2c5169Ac";
  const tokenRegistryAddress = "0xC9121f5B33F2926539440d44dC0a8E45aCc65F05";
  const minersNFTPriceInit = "1000000";
  const nodesNFTPricesInit = ["1000000", "2000000", "3000000"];

  // -------------------------------- TokenRegistry------------------------------------------ //
  //*this is simple token registry deployment script, not the upgradable
  // const TokenRegistry = await hre.ethers.deployContract('TokenRegistry', []);
  // console.log('Deploying TokenRegistry...');
  // await TokenRegistry.waitForDeployment();
  // console.log('TokenRegistry deployed to:', TokenRegistry.target);
  // await new Promise((resolve) => setTimeout(resolve, 30000));
  // verify('0xC9121f5B33F2926539440d44dC0a8E45aCc65F05', []);
  // console.log('TokenRegistry Verified');
  // return;

  //------------------------------- MinerNFT------------------------------------------ //
  //   const MinerNFT = await hre.ethers.deployContract("MinerNFT", []);
  //   console.log("Deploying MinerNFT...");
  //   await MinerNFT.waitForDeployment();
  //   console.log("MinerNFT deployed to:", MinerNFT.target);
  //   await new Promise((resolve) => setTimeout(resolve, 30000));
  //   verify("0xD6D2061CBfdF81b56c37d8cC6C9c2A9AA7F51931", []);
  //   console.log("MinerNFT Verified");
  //   return;

  // -------------------------------- NodeNft------------------------------------------ //
  const NodeNft = await hre.ethers.deployContract("NodeNft", []);
  console.log("Deploying NodeNft...");
  await NodeNft.waitForDeployment();
  console.log("NodeNft deployed to:", NodeNft.target);
  await new Promise((resolve) => setTimeout(resolve, 30000));
  verify(NodeNft.target, []);
  console.log("NodeNft Verified");
  return;

  // -------------------------------- CLAIMS------------------------------------------ //
  //   const Claims = await hre.ethers.deployContract("Claims", [
  //     projectWalletAddress,
  //   ]);
  //   console.log("Deploying Claims...");
  //   await Claims.waitForDeployment();
  //   console.log("Claims deployed to:", Claims.target);
  //   await new Promise((resolve) => setTimeout(resolve, 30000));
  //   verify("0x8FD72071eeb0D49Db5Ca5FfC0e781d0f023D485B", [projectWalletAddress]);
  //   console.log("Claims Verified");
  //   return;

  // -------------------------------- TokenRegistry------------------------------------------ //

  /// @param projectWalletAddress The address of project wallet
  /// @param platformWalletAddress The address of platform wallet
  /// @param burnWalletAddress The address of burn wallet
  /// @param signerAddress The address of signer wallet
  /// @param owner The address of owner wallet
  /// @param gemsAddress The address gems contract
  /// @param usdtAddress The address of usdt contract
  /// @param claimsContractAddress The address of claim contract
  /// @param minerNftContractAddress The address of miner nft contract
  /// @param nodeNftContractAddress The address of miner nft contract
  /// @param tokenRegistryAddress The address of token registry contract
  /// @param minersNFTPriceInit The price of minor nft
  /// @param nodesNFTPricesInit The prices of node nfts

  const PreSale = await hre.ethers.deployContract("PreSale", [
    projectWalletAddress,
    platformWalletAddress,
    burnWalletAddress,
    signerAddress,
    owner,
    gemsAddress,
    usdtAddress,
    claimsContractAddress,
    minerNftContractAddress,
    nodeNftContractAddress,
    tokenRegistryAddress,
    minersNFTPriceInit,
    nodesNFTPricesInit,
  ]);
  console.log("Deploying PreSale...");
  await PreSale.waitForDeployment();
  console.log("PreSale deployed to:", PreSale.target);
  await new Promise((resolve) => setTimeout(resolve, 30000));
  verify("0x8a5F1afd55d5AE0637Abc2100815b7CFb43cEFF2", [
    projectWalletAddress,
    platformWalletAddress,
    burnWalletAddress,
    signerAddress,
    owner,
    gemsAddress,
    usdtAddress,
    claimsContractAddress,
    minerNftContractAddress,
    nodeNftContractAddress,
    tokenRegistryAddress,
    minersNFTPriceInit,
    nodesNFTPricesInit,
  ]);
  console.log("PreSale Verified");
  return;

  // -----------------------------------  Price - Feed ----------------------------------- //
  const tokenRegistry = await hre.ethers.getContractAt(
    "TokenRegistry",
    tokenRegistry.target
  );
  const priceFeedTokens = [ETH, USDC, WBTC, LINK];
  const priceFeedData = [
    {
      priceFeed: "0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70", // ETH price feed
      normalizationFactorForToken: TOKEN_NF_ETH,
      tolerance: TOLERANCE_ETH,
    },
    {
      priceFeed: "0x7e860098F58bBFC8648a4311b374B1D669a2bc6B", // USDT price feed
      normalizationFactorForToken: TOKEN_NF_USDT_USDC,
      normalizationFactorForNFT: NFT_NF_USDT_USDC,
      tolerance: TOLERANCE_USDT_USDC,
    },
    {
      priceFeed: "0x71041dddad3595F9CEd3DcCFBe3D1F4b0a16Bb70", // WETH price feed
      normalizationFactorForToken: TOKEN_NF_USDT_USDC,
      normalizationFactorForNFT: NFT_NF_USDT_USDC,
      tolerance: TOLERANCE_USDT_USDC,
    },
    {
      priceFeed: "0x64c911996D3c6aC71f9b455B1E8E7266BcbD848F", // WBTC price feed
      normalizationFactorForToken: TOKEN_NF_WBTC,
      normalizationFactorForNFT: NFT_NF_WBTC,
      tolerance: TOLERANCE_WBTC,
    },
  ];
  tokenRegistry.setTokenPriceFeed(priceFeedTokens, priceFeedData);
  console.log("Pricefeed Set");

  //   // -------------------------------- Implementation(Presale)------------------------------------------ //
  // const PreSale = await hre.ethers.deployContract('PreSale', []);
  // console.log('Deploying PreSale...');
  // await PreSale.waitForDeployment();
  // console.log('PreSale deployed to:', PreSale.target);
  // await new Promise((resolve) => setTimeout(resolve, 200));
  // verify(PreSale.target, []);
  // console.log('PreSale Verified');

  //   // -------------------------------- BEACON------------------------------------------ //
  const implementation = await hre.ethers.getContractAt(
    "PreSale",
    PreSale.target
  );

  const Beacon = await hre.ethers.deployContract("Beacon", [
    implementation.target,
    ownerAddress,
  ]);
  console.log("Deploying Beacon...");
  await Beacon.waitForDeployment();
  console.log("Beacon deployed to:", Beacon.target);
  await new Promise((resolve) => setTimeout(resolve, 200));
  verify(Beacon.target, [implementation.target, ownerAddress]);
  console.log("Beacon Verified");

  //   // -------------------------------- ProxyFactory------------------------------------------ //
  const ProxyFactory = await hre.ethers.deployContract("ProxyFactory", [
    tokenRegistryAddress,
    platformWalletAddress,
    ownerAddress,
    signerAddress,
    feeAmount,
  ]);
  console.log("Deploying ProxyFactory...");
  await ProxyFactory.waitForDeployment();
  console.log("ProxyFactory deployed to:", ProxyFactory.target);
  await new Promise((resolve) => setTimeout(resolve, 200));

  verify(ProxyFactory.target, [
    tokenRegistryAddress,
    platformWalletAddress,
    ownerAddress,
    signerAddress,
    feeAmount,
  ]);
  console.log("BeaconProxyFactory Verified");

  //   // -----------------------------------  grant-admin-role-to-factory ----------------------------------- //

  const lockLiquidityContract = await hre.ethers.getContractAt(
    "LockLiquidity",
    LockLiquidity.target
  );

  await lockLiquidityContract.grantRole(ADMIN_ROLE, owner);
  console.log("Has role:::");
  // -------------------------------- Creating Presale------------------------------------------ //

  const proxyFactoryContract = await hre.ethers.getContractAt(
    "ProxyFactory",
    ProxyFactory.target
  );
  const beaconContract = await hre.ethers.getContractAt(
    "Beacon",
    Beacon.target
  );

  console.log("ProxyFactory:::", proxyFactoryContract);

  //PresaleToken needs to be in contracts for getting presaleToken contract
  const presaleToken = await hre.ethers.getContractAt(
    "PresaleToken",
    data.presaleTokenContractAddress
  );
  console.log("presaleToken===", presaleToken);

  const amount = await presaleToken.balanceOf(ownerAddress);
  console.log("amount==", amount);

  const tx1 = await presaleToken.approve(proxyFactoryContract, amount);
  await tx1.wait();
  console.log("approval done");

  const allowance = await presaleToken.allowance(
    ownerAddress,
    proxyFactoryContract
  );
  console.log("Allowance:", allowance.toString());

  //creating presale
  //*owner is serving as sale token wallet
  const tx = await proxyFactoryContract.createProxy(
    beaconContract,
    data,
    ownerAddress
  );

  const receipt = await tx.wait();
  console.log("Transaction hash:", tx.hash);
  console.log("Transaction receipt:", receipt);
}

main();
