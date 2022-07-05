const main = async () => {
  // const domainContractFactory = await hre.ethers.getContractFactory('Domains');

  // // We pass in "programwithyt" to the constructor when deploying
  // const domainContract = await domainContractFactory.deploy('programwithyt');
  // await domainContract.deployed();

  // console.log('Contract deployed to:', domainContract.address);

  // // We're passing in a second variable - value. This is the moneyyyyyyyyyy
  // let txn = await domainContract.register('ErikYT', {
  //   value: hre.ethers.utils.parseEther('0.1'),
  // });
  // await txn.wait();

  // const address = await domainContract.getAddress('ErikYT');
  // console.log('Owner of domain programwithyt:', address);

  // const balance = await hre.ethers.provider.getBalance(domainContract.address);
  // console.log('Contract balance:', hre.ethers.utils.formatEther(balance));


  const nftContractFactory = await hre.ethers.getContractFactory("MyEpicNFT");
  const nftContract = await nftContractFactory.deploy();
  await nftContract.deployed();
  console.log("Contract deployed to:", nftContract.address);

  // Call the function.
  let txn = await nftContract.makeAnEpicNFT();
  // Wait for it to be mined.
  await txn.wait();

  // Mint another NFT for fun.
  txn = await nftContract.makeAnEpicNFT();
  // Wait for it to be mined.
  await txn.wait();
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
