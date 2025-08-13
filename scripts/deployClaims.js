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
    const signer = '0x55e39d81cF66F57e32E1F7d75b666BDDfad23896'; //updated
    // this is basically funds wallet, used for transferring funds when revoked claim
    const fundsWallet_To_Transfer_Revoked_Funds = '0x7b3A848119f61B88a7E505A107ABdA6414c50941'; // owner wallet updated

    const Claims = await hre.ethers.deployContract('Claims', [signer, fundsWallet_To_Transfer_Revoked_Funds]);

    console.log('Deploying Claims...');
    await Claims.waitForDeployment();
    console.log('Claims deployed to:', Claims.target);

    await new Promise((resolve) => setTimeout(resolve, 20000));
    verify(Claims.target, [signer, fundsWallet_To_Transfer_Revoked_Funds]);
}

main();
