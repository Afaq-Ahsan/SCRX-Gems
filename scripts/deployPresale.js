const hre = require('hardhat');
const { run } = require('hardhat');
async function verify(address, constructorArguments) {
    console.log(`verify  ${address} with arguments ${constructorArguments.join(',')}`);
    await run('verify:verify', {
        address,
        constructorArguments
    });
}

async function main() {
    const projectWallet = '0x60bCf12A2dA761E909C3bc29f1cD13Ef1e4847A0';
    const platFormWallet = '0xA2F78A912BA4337692a399407728784FB6B24FB1';
    const burnWallet = '0xe1dE0eF1fa1F3e5e1f2b2aD134Fb2C3135CEfa3B';
    const signer = '0x8002917a84DB1B1Ef57f7Cf0B19f5F5c611db9D5';
    const claim = '0x1890cF752f1be4D60f3b22168c7A6aFEbd9D74C7';
    const lockup = '0x6A1aa5ac35f38Bdb25BBD976E8eca942b23260b2';
    const owner = '0x5D7F0ED4EA8EB7a6e0A6Acf1DE9c91Be06968716';
    const lastround = 0;
    const prices = [
        process.env.PRICES0,
        process.env.PRICES1,
        process.env.PRICES2,
        process.env.PRICES3,
        process.env.PRICES4,
        process.env.PRICES5,
        process.env.PRICES6
    ];

    const maxCap = '5250000000000000000000000000';

    const PreSale = await hre.ethers.deployContract('PreSale', [
        projectWallet,
        platFormWallet,
        burnWallet,
        signer,
        claim,
        lockup,
        owner,
        lastround,
        prices,
        maxCap
    ]);

    console.log('Deploying PreSale...');
    await PreSale.waitForDeployment();
    console.log('PreSale deployed to:', PreSale.target);

    await new Promise((resolve) => setTimeout(resolve, 20000));
    verify(PreSale.target, [
        projectWallet,
        platFormWallet,
        burnWallet,
        signer,
        claim,
        lockup,
        owner,
        lastround,
        prices,
        maxCap
    ]);
}

main();
