const { ethers } = require("hardhat");

async function main() {
  console.log("Deploying FreelanceEscrow contract to Core Blockchain...");

  // Get the ContractFactory and Signers here
  const FreelanceEscrow = await ethers.getContractFactory("FreelanceEscrow");
  
  // Deploy the contract
  const freelanceEscrow = await FreelanceEscrow.deploy();
  
  // Wait for the contract to be deployed
  await freelanceEscrow.deployed();

  console.log("FreelanceEscrow contract deployed to:", freelanceEscrow.address);
  console.log("Transaction hash:", freelanceEscrow.deployTransaction.hash);
  
  // Verify deployment
  const owner = await freelanceEscrow.signer.getAddress();
  console.log("Deployed by:", owner);
  console.log("Network:", "Core Testnet");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error deploying contract:", error);
    process.exit(1);
  });
