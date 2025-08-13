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
    const fundwallet = process.env.FUNDS_WALLET;
    const signer = process.env.SIGNER;
    const owner = process.env.INITIAL_OWNER;

    const PreSale = await hre.ethers.deployContract('PreSaleInstitution', [fundwallet, signer, owner]);
    console.log('Deploying PreSale...');
    await PreSale.waitForDeployment();
    console.log('PreSale deployed to:', PreSale.target);
    await new Promise((resolve) => setTimeout(resolve, 20000));

    verify(PreSale.target, [fundwallet, signer, owner, initMaxCap]);
}
main();

