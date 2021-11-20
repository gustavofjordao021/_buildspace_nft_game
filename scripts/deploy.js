const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Uzumaki Naruto", "Uchiha Sasuke", "Hatake Kakashi"], // Names
    [
      "https://static.wikia.nocookie.net/naruto/images/4/42/Naruto_Part_III.png", // Images
      "https://static.wikia.nocookie.net/naruto/images/b/b7/Sasuke_Part_3.png",
      "https://static.wikia.nocookie.net/naruto/images/2/27/Kakashi_Hatake.png",
    ],
    [200, 150, 120], // HP values
    [200, 150, 120], // MaxHP values
    [120, 100, 80], // Chakra values
    [50, 50, 40], // Attack damage values
    "Ōtsutsuki Kaguya", // Boss name
    "https://static.wikia.nocookie.net/naruto/images/6/6c/Kaguya_%C5%8Ctsutsuki.png", // Boss image
    1000, // Boss hp
    500, // Boss chakra
    50 // Boss attack damage
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
