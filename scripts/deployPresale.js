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
    
 const projectWallet = '0x6F0A2017947a1a9c87F5d3a334BB909026fd1109';
    const platFormWallet = '0x22dA5C97F742eC3828a8183896dA56B44eFd0471';
    const burnWallet = '0xF14aEB1Cb06c674B58D87D2Cc2dfc4b1e9f4EdB6';
    const signer = '0x12eF0F1C99D8FD50fFd37cCd12B09Ef7f1213269';
    const claim = '0xD527EbfA255E4E751Db6d6baC4555F7650f87224';
    const lockup = '0x034f504F34330eA87dcc8aBae2935eac9fD2eFaE';
    const subscription = '0xe7Ad3a7EC2fdc8aa141dB9AFc1f701AAb579DA85';
    const owner = '0x7b3A848119f61B88a7E505A107ABdA6414c50941';
    const lastround = 0;
    const maxCap = '200000000000000000000000000';

    const PreSale = await hre.ethers.deployContract(
        'PreSale',
        [projectWallet, platFormWallet, burnWallet, signer, claim, lockup, subscription, owner, lastround, maxCap],
        {
            gasLimit: 6000000
        }
    );

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
        subscription,
        owner,
        lastround,
        maxCap
    ]);
}

main();

