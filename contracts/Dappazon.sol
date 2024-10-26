// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Dappazon {
    address public owner;

    struct Item {
        uint256 id;
        string name;
        string category;
        string image;
        uint256 cost;
        uint256 rating;
        uint256 stock;
    }

    struct Order {
        uint256 timestamp;
        Item item;
    }

    mapping(uint256 => Item) public items;
    mapping(address => uint256) public orderCount;
    mapping(address => mapping(uint256 => Order)) public orders;


    event List(string name, uint256 cost, uint256 quantity);
    event Buy(address buyer, uint256 orderId, uint256 itemId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    //List Products
    function list(
        uint256 _id,
        string memory _name,
        string memory _category,
        string memory _image,
        uint256 _cost,
        uint256 _rating,
        uint256 _stock
    ) public onlyOwner {
        //Create Item struct in memory
        Item memory item = Item(
            _id,
            _name,
            _category,
            _image,
            _cost,
            _rating,
            _stock
        );

        //Save Items struct to blockchain
        items[_id] = item;

        //Emit event
        emit List(_name, _cost, _stock);
    }

    //Buy Products
    function buy(uint256 _id) public payable {
        //Fetch the item
        Item memory item = items[_id];

        require(msg.value >= item.cost, "Insufficient funds sent");
        require(item.stock > 0, "Item is out of stock");


        //Create an order
        Order memory order = Order(block.timestamp, item);

        //Save the order to blockchain
        orderCount[msg.sender]++;
        orders[msg.sender][orderCount[msg.sender]] = order;

        //Subtract stock
        items[_id].stock = item.stock - 1;

        //Emit an event
        emit Buy(msg.sender, orderCount[msg.sender], _id);
    }

    //Withdraw Funds
    function withdraw() public onlyOwner {
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Failed to send Ether");
    }
}