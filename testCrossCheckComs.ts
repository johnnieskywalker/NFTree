// import  ethers from 'ethers';

// import {L1Root} from "./typechain/L1Root"
// import {L2Root} from "./typechain/L2Root"

const ethers = require('ethers')
const Watcher = require('@eth-optimism/core-utils').Watcher
const { getContractFactory } = require('@eth-optimism/contracts')

// Set up some contract factories. You can ignore this stuff.
const factory = (name, ovm = false) => {
  const artifact = require(`./artifacts${ovm ? '-ovm' : ''}/contracts/${name}.sol/${name}.json`)
  return new ethers.ContractFactory(artifact.abi, artifact.bytecode)
}
const factoryL1Root = factory('L1Root');
const factoryL2Root = factory('L2Root', true);
// const factory__L1_ERC20Gateway = getContractFactory('OVM_L1ERC20Gateway')


async function main_old() {
  // Set up our RPC provider connections.
  const l1RpcProvider = new ethers.providers.JsonRpcProvider('http://localhost:9545')
  const l2RpcProvider = new ethers.providers.JsonRpcProvider('http://localhost:8545')

  // Set up our wallets (using a default private key with 10k ETH allocated to it).
  // Need two wallets objects, one for interacting with L1 and one for interacting with L2.
  // Both will use the same private key.
  const key = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
  const l1Wallet = new ethers.Wallet(key, l1RpcProvider)
  const l2Wallet = new ethers.Wallet(key, l2RpcProvider)

  // L1 messenger address depends on the deployment, this is default for our local deployment.
  const l1MessengerAddress = '0x59b670e9fA9D0A427751Af201D676719a970857b'
  // L2 messenger address is always the same.
  const l2MessengerAddress = '0x4200000000000000000000000000000000000007'

  // Tool that helps watches and waits for messages to be relayed between L1 and L2.
  const watcher = new Watcher({
    l1: {
      provider: l1RpcProvider,
      messengerAddress: l1MessengerAddress
    },
    l2: {
      provider: l2RpcProvider,
      messengerAddress: l2MessengerAddress
    }
  });

  // const contractFactory = await ethers.getContractFactory("Root", signer);

  console.log("Deploy L1Root");
  const l1Root = await factoryL1Root.connect(l1Wallet).deploy({
    gasPrice: 0
  });
  await l1Root.deployTransaction.wait();

  console.log("Deploy L2Root");
  const l2Root = await factoryL2Root.connect(l2Wallet).deploy(
    l1Root.address,
    l2MessengerAddress,
    { gasPrice: 0 }
  );
  await l2Root.deployTransaction.wait();

  console.log("Call mint from L2 -> L1");
  const txMint = await l2Root.testCrossChainMint(l1Wallet.address, {
    gasPrice: 0
  });
  await txMint.wait();

  // Wait for the message to be relayed to L1
  console.log('Waiting for message to be relayed to L1...')
  const [ msgHash1 ] = await watcher.getMessageHashesFromL2Tx(txMint.hash)
  await watcher.getL1TransactionReceipt(msgHash1)

  console.log("Check if L1 was successfully called")
  const wasMintTreeCalled = await l1Root.wasMintTreeCalled();
  console.log("Was L1 called = ", wasMintTreeCalled);

}

async function main_new() {
  // Set up our RPC provider connections.
  const l1RpcProvider = new ethers.providers.JsonRpcProvider('http://localhost:9545')
  const l2RpcProvider = new ethers.providers.JsonRpcProvider('http://localhost:8545')

  // Set up our wallets (using a default private key with 10k ETH allocated to it).
  // Need two wallets objects, one for interacting with L1 and one for interacting with L2.
  // Both will use the same private key.
  const key = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'
  const l1Wallet = new ethers.Wallet(key, l1RpcProvider)
  const l2Wallet = new ethers.Wallet(key, l2RpcProvider)

  // L1 messenger address depends on the deployment, this is default for our local deployment.
  const l1MessengerAddress = '0x59b670e9fA9D0A427751Af201D676719a970857b'
  // L2 messenger address is always the same.
  const l2MessengerAddress = '0x4200000000000000000000000000000000000007'

  // Tool that helps watches and waits for messages to be relayed between L1 and L2.
  const watcher = new Watcher({
    l1: {
      provider: l1RpcProvider,
      messengerAddress: l1MessengerAddress
    },
    l2: {
      provider: l2RpcProvider,
      messengerAddress: l2MessengerAddress
    }
  });

  // const contractFactory = await ethers.getContractFactory("Root", signer);

  console.log("Deploy L1Root");
  const l1Root = await factoryL1Root.connect(l1Wallet).deploy(
    l2Wallet.address,  // this is not used (could be any address) in the example we only send data from L2 -> L1
    l1MessengerAddress,
    {gasPrice: 0}
    );
  await l1Root.deployTransaction.wait();

  console.log("Deploy L2Root");
  const l2Root = await factoryL2Root.connect(l2Wallet).deploy(
    l1Root.address,
    l2MessengerAddress,
    { gasPrice: 0 }
  );
  await l2Root.deployTransaction.wait();

  console.log("Create tree on L2 ");
  const hashRoot = "root1";
  const hashNodeOne = "node1";
  const hashNodeTwo = "node2";
  const hashNodeThree = "node3";
  const hashNodeFour = "node4";

  // const treeAsArray: string[][] = [ //TODO - update config to user TS, error here is cos of pure js ?
  const treeAsArray = [
    [hashRoot, hashNodeOne, hashNodeTwo],
    [hashNodeOne, hashNodeThree],
    [hashNodeThree, hashNodeFour]
  ];

  const txMintTree = await l2Root.mintTree(l2Wallet.address, treeAsArray);
  await txMintTree.wait();  

  console.log("Call mint from L2 -> L1");
  const rootId = await l2Root.getNodeIdForHash(hashRoot);
  const txMint = await l2Root.crossChainMint(l1Wallet.address, rootId, {
    gasPrice: 0
  });
  await txMint.wait();

  // Wait for the message to be relayed to L1
  console.log('Waiting for message to be relayed to L1...')
  const [ msgHash1 ] = await watcher.getMessageHashesFromL2Tx(txMint.hash)
  await watcher.getL1TransactionReceipt(msgHash1)

  console.log("Check if L1 was successfully called")
  const wasMintTreeCalled = await l1Root.wasMintTreeCalled();
  console.log("Was L1 called = ", wasMintTreeCalled);

  console.log("Check minted tree")
  const recreatedTreeAsHashes = await l1Root.buildTreeForExportWithHash(rootId);
  console.log("recreated tree as hashes: ", recreatedTreeAsHashes);

}

main_new()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error)
    process.exit(1)
  });


