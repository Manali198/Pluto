import { ethers } from 'hardhat';

async function main(): Promise<void> {
  const [deployer] = await ethers.getSigners();

  console.log('Contract deployment using the account:', deployer.address);

  const USDT = await ethers.getContractFactory('USDT');
  const usdttoken = await USDT.deploy();

  await usdttoken.waitForDeployment(); 

  console.log('Testingrev contract address:', await usdttoken.getAddress());

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });