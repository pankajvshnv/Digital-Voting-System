// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
const hre = require("hardhat");

async function main() {
  console.log("Deploying TransparentVoting contract...");

  // Sample proposals for deployment
  const proposalNames = ["Proposal 1", "Proposal 2", "Proposal 3"];
  const proposalDescriptions = [
    "Description for proposal 1",
    "Description for proposal 2",
    "Description for proposal 3"
  ];

  // Voting period (24 hours from now)
  const now = Math.floor(Date.now() / 1000); // Current time in seconds
  const startTime = now;
  const endTime = now + 86400; // 24 hours later

  // Deploy TransparentVoting contract
  const TransparentVoting = await hre.ethers.getContractFactory("TransparentVoting");
  const voting = await TransparentVoting.deploy(
    proposalNames,
    proposalDescriptions,
    startTime,
    endTime
  );

  await voting.deployed();

  console.log(`TransparentVoting deployed to: ${voting.address}`);
  console.log(`Start time: ${new Date(startTime * 1000).toLocaleString()}`);
  console.log(`End time: ${new Date(endTime * 1000).toLocaleString()}`);
  console.log(`Number of proposals: ${proposalNames.length}`);

  // Log verification command
  console.log("\nVerification command:");
  console.log(
    `npx hardhat verify --network ${hre.network.name} ${voting.address} "${JSON.stringify(proposalNames).replace(/"/g, '\\"')}" "${JSON.stringify(proposalDescriptions).replace(/"/g, '\\"')}" ${startTime} ${endTime}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});