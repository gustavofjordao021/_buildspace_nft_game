const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Uzumaki Naruto", "Uchiha Sasuke", "Hatake Kakashi"], // Names
    [
      "https://static.wikia.nocookie.net/boruto/images/9/9d/375px-NarutoBorutoMovie.jpg/revision/latest?cb=20200121144920", // Images
      "https://static.wikia.nocookie.net/boruto/images/b/b7/Sasuke_Epilogue.png/revision/latest?cb=20170912000355",
      "https://s4.anilist.co/file/anilistcdn/character/large/b85-mkVBh2yjxjmx.png",
    ],
    [200, 150, 120], // HP values
    [200, 150, 120], // MaxHP values
    [120, 100, 80], // Chakra values
    [50, 50, 40], // Attack damage values
    "Ōtsutsuki Kaguya", // Boss name
    "https://static.wikia.nocookie.net/naruto/images/6/6c/Kaguya_%C5%8Ctsutsuki.png/revision/latest/scale-to-width-down/2000?cb=20180824113908", // Boss image
    1000, // Boss hp
    500, // Boss chakra
    50 // Boss attack damage
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  let txn;
  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  let returnedTokenUri = await gameContract.tokenURI(1);
  console.log("Token URI:", returnedTokenUri);
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
