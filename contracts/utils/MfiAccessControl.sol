// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/AccessControl.sol";


abstract contract MfiAccessControl is AccessControl {

    // money administrator
    bytes32 public constant MONEY_ADMINISTRATOR = bytes32("MFI_Money_Administrator");

    // data administrator
    bytes32 public constant DATA_ADMINISTRATOR = bytes32("MFI_Data_Administrator");

    // project administrator
    bytes32 public constant PROJECT_ADMINISTRATOR = bytes32("MFI_Project_Administrator");

    // update administrator
    bytes32 public constant UPDATE_ADMINISTRATOR = bytes32("MFI_Update_Administrator");


}
