import hre, { ethers } from "hardhat";

async function main() {
  // todo : make this dynamic, this would only work for goerli's entrypoint
  const entryPoint = "0x0576a174D229E3cFA37253523E645A78A0C91B57";
  const contract = await ethers.deployContract("AutoPilotFactory", [
    entryPoint,
  ]);

  await contract.deployed();

  console.log("AutoPilotFactory deployed to:", contract.address);

  // Uncomment if you want to enable the `tenderly` extension
  // await hre.tenderly.verify({
  //   name: "Greeter",
  //   address: contract.address,
  // });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
