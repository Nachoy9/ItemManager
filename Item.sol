//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ItemManager.sol";

contract Item {

    uint public itemPrice;
    uint public itemPaid;
    uint public itemIndex;

    ItemManager parentContract;

    constructor(ItemManager _parentContract, uint _itemPrice, uint _itemIndex) public { 
        itemPrice = _itemPrice;
        itemIndex = _itemIndex;
        parentContract = _parentContract;
    }

    receive() external payable {
        require(msg.value == itemPrice, "Only full payments");
        require(itemPaid == 0, "Item already paid");

        itemPaid += msg.value;

        //check that Item contract call of payment function of ItemManager, with the same msg.value, was succesful
        (bool success, ) = address(parentContract).call{value:msg.value}(abi.encodeWithSignature("payForItem(uint256)", itemIndex));
        
        require(success, "Payment did not work");
    }

}