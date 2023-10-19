import { ethers } from 'hardhat';

async function main(): Promise<void> {
  const [deployer] = await ethers.getSigners();

  console.log('Contract deployment using the account:', deployer.address);

  const PlutopeToken = await ethers.getContractFactory('PlutopeToken');
  const plutopetoken = await PlutopeToken.deploy("0x02B100eB8b9064Aa716B837F81e943Bdc006A8bE");

  await plutopetoken.waitForDeployment();

  console.log('plutopetoken contract address:', await plutopetoken.getAddress());

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });