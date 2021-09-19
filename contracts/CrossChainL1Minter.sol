pragma solidity >=0.6.0 <0.8.0;

pragma experimental ABIEncoderV2;

/* Library Imports */
import { OVM_CrossDomainEnabled } from "@eth-optimism/contracts/libraries/bridge/OVM_CrossDomainEnabled.sol";

import { ITreeMinter } from "./ITreeMinter.sol";

// TODO: make as universal CrossChainMinter for both L1 and L2 (just name args as lAMinter and lBMessenger)
abstract contract CrossChainL1Minter is OVM_CrossDomainEnabled {

  // amount of gas used to finish transaction on L2 (taken from l2->l1 optimism exmaple)
  uint32 internal constant L2_GAS = 2000000;

  /********************************
    * External Contract References *
    ********************************/

  address public l2Minter;

  constructor(address _l2Minter, address _l1messenger) OVM_CrossDomainEnabled(_l1messenger) {
    l2Minter = _l2Minter;        
  }

  function mintOnL2(address l2Owner, string[][] memory tree) internal {
    
    bytes memory data = abi.encodeWithSelector(
      ITreeMinter.mintTree.selector,
      l2Owner,
      tree
    );

    // Send calldata into L2
    sendCrossDomainMessage(
      l2Minter,
      L2_GAS,
      data
    );
  }

  function sendString(address l2Owner, string memory strData) internal {
    
    bytes memory data = abi.encodeWithSelector(
      ITreeMinter.crossChainStringTransfer.selector,
      l2Owner,
      strData
    );

    // Send calldata into L2
    sendCrossDomainMessage(
      l2Minter,
      L2_GAS,
      data
    );
  }

  function sendStringArray(address l2Owner, string[][] memory strArrData) internal {
    bytes memory data = abi.encodeWithSelector(
      ITreeMinter.crossChainStringArrayTransfer.selector,
      l2Owner,
      strArrData
    );

    // Send calldata into L2
    sendCrossDomainMessage(
      l2Minter,
      L2_GAS,
      data
    );
  }

}



