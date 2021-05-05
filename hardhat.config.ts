/**
 * @type import('hardhat/config').HardhatUserConfig
 */

 import { HardhatUserConfig } from "hardhat/types";

 import "@nomiclabs/hardhat-waffle";
 import "hardhat-typechain";
 import '@eth-optimism/hardhat-ovm';
 
 const config: HardhatUserConfig = {
     defaultNetwork: "hardhat",
     solidity: {
         compilers: [{ version: "0.7.3", settings: {} }],
       },
     networks: {
       hardhat: {},
       optimism: {
        url: 'http://127.0.0.1:8545',
        accounts: {
          mnemonic: 'test test test test test test test test test test test junk'
        },
        // This sets the gas price to 0 for all transactions on L2. We do this
        // because account balances are not automatically initiated with an ETH
        // balance (yet, sorry!).
        gasPrice: 0,
        ovm: true // This sets the network as using the ovm and ensure contract will be compiled against that.
      }
       // rinkeby: {
       //   url: `https://ropsten.infura.io/v3/5e51ff14ecd24a7faf37b5311c4bd61e`,
       //   accounts: [RINKEBY_PRIVATE_KEY],
       // },
     },  
 };
 export default config;
 
 
 
 