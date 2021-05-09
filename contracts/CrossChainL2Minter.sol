pragma solidity >=0.6.0 <0.8.0;

pragma experimental ABIEncoderV2;

/* Library Imports */
import { OVM_CrossDomainEnabled } from "@eth-optimism/contracts/libraries/bridge/OVM_CrossDomainEnabled.sol";

import { IL1Minter } from "./IL1Minter.sol";

abstract contract CrossChainL2Minter is OVM_CrossDomainEnabled {

  // test value for gas - check what is the correct one 
  uint32 internal constant DEFAULT_MINT_L1_GAS = 1200000;

  /********************************
    * External Contract References *
    ********************************/

  address public l1Minter;

  constructor(address _l1Minter, address _l2messenger) OVM_CrossDomainEnabled(_l2messenger) {
    l1Minter = _l1Minter;        
  }

  function mintOnL1(address l1Owner, string[][] storage tree) internal {
    
    bytes memory data = abi.encodeWithSelector(
      IL1Minter.mintTree.selector,
      l1Owner,
      tree
    );

    // Send calldata into L2
    sendCrossDomainMessage(
      l1Minter,
      data,
      DEFAULT_MINT_L1_GAS
    );
  }

}



