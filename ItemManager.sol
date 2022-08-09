//SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Ownable.sol";
import "./Item.sol";

contract ItemManager is Ownable {

    enum SupplyChainState {Created, Paid, Delivered} //the item can only have one of these states

    struct ItemStruct {
        Item _item;
        string _identifier; //the item has a name
        uint _itemPrice; //the item gas a price
        ItemManager.SupplyChainState _state; //the item has a state already defined
    }

    mapping(uint => ItemStruct) public items;
    uint itemIndex;

    event SupplyChainStep(uint _itemIndex, uint _step, address _address); //enums have as mmany steps as definitions starting from 0

    function createItem(string memory _identifier, uint _itemPrice) public OnlyOwner {
        Item item = new Item(this, _itemPrice, itemIndex); //each time an item es created, a new smart contract is created

        items[itemIndex]._item = item;
        items[itemIndex]._identifier = _identifier; 
        items[itemIndex]._itemPrice = _itemPrice;
        items[itemIndex]._state = SupplyChainState.Created;

        emit SupplyChainStep(itemIndex, uint(items[itemIndex]._state), address(item));

        itemIndex++; //next created item will have different index
    }

    function payForItem(uint _itemIndex) public payable {
        Item item = items[_itemIndex]._item;

        require(address(item) == msg.sender, "Only items allowed to update themselves");
        require(item.itemPrice() == msg.value, "Only full payment");
        require(items[_itemIndex]._itemPrice <= msg.value, "Wrong price");
        require(items[_itemIndex]._state == SupplyChainState.Created, "Item not in stock");

        items[_itemIndex]._state = SupplyChainState.Paid;

        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(item));
    }

    function deliverItem(uint _itemIndex) public OnlyOwner {
        require(items[_itemIndex]._state == SupplyChainState.Paid, "Item don't exist, it's not paid or has been delivered already");

        items[_itemIndex]._state = SupplyChainState.Delivered;

        emit SupplyChainStep(_itemIndex, uint(items[_itemIndex]._state), address(items[_itemIndex]._item));
    }
}