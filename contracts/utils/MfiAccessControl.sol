// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControl.sol";


abstract contract MfiAccessControl is AccessControl {

    uint256 public proportion = 100;

    uint256 public constant MAX = ~uint256(0);

    // money administrator
    bytes32 public constant MONEY_ADMINISTRATOR = bytes32(keccak256(abi.encodePacked("MFI_Money_Administrator")));

    // data administrator
    bytes32 public constant DATA_ADMINISTRATOR = bytes32(keccak256(abi.encodePacked("MFI_Data_Administrator")));

    // project administrator
    bytes32 public constant PROJECT_ADMINISTRATOR = bytes32(keccak256(abi.encodePacked("MFI_Project_Administrator")));

    // meta finance trigger pool address
    bytes32 public constant META_FINANCE_TRIGGER_POOL = bytes32(keccak256(abi.encodePacked("META_FINANCE_TRIGGER_POOL")));


}
