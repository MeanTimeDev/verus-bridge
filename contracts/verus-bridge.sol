// SPDX-License-Identifier: MIT
// Bridge between ethereum and verus

pragma solidity >=0.4.21 <0.7.0;

import "../node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Factory.sol";

contract verusBridge is Ownable{

    address public owner;
    //list of erc20 tokens that can be accessed,
    //the contract must be able to mint and burn coins on the contract
    //list of addresses allowed to execute transactions
    address[] private permittedAddresses;
    //defines the factory which creates the erc20
    Factory factory;

    //pending transactions array
    struct SendTransaction {
        address targetAddress;
        string tokenName;
        uint tokenAmount;
    }
    SendTransaction[] private pendingTransactions;

    constructor() public {
         owner = msg.sender;
    }

    function receiveFromVerus(string tokenName,  uint tokenAmount, address targetAddress) public {
        factory.mintToken(tokenName,tokenAmount,targetAddress);
    }

    function sendToVerus(string tokenName, uint tokenAmount, address targetAddress) public {
        //call the burn of the amount
        //add to pending transactions array
        //need to check that
        factory.burnToken(tokenName,tokenAmount);
        pendingTransactions.push(SendTransaction(targetAddress,tokenAmount,tokenName));
    }

    function pendingTransactions() public {
        return pendingTransactions;
    }

    //returns the array of transactions to be processed
    //only users in the permitted address list can perform this transaction
    function completeTransactions() public {
        require(permittedAddresses[msg.sender],"Address not permitted to complete transactions");
        pendingTransactions = new SendTransaction[];
    }

    function createToken(string verusAddress,string ticker) public{
        factory.deployNewToken(verusAddress,ticker);
    }

    function addAllowedAddress(address newAddress) public onlyOwner {
        permittedAddresses.push(newAddress);
    }

    function removeAllowedAddress(address removeAddress) public onlyOwner {
        //permittedAddresses.push(newAddress);
        address[] memory temporaryAddressList = new address[];
        for(uint i = 0;i<array.length;i++){
            if(permittedAddresses[i] != removeAddress){
                temporaryAddressList.push(permittedAddresses[i]);
            }
        }
        permittedAddresses = temporartAddressList;

    }

}
