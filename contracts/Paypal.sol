// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract Paypal {
    address public owner;

    constructor() {
        owner == msg.sender;
    }

    //1. for the request
    struct request {
        address requestor;
        uint amount;
        string message;
        string name;
    }
    // 2.for the send amd Recieve functions
    struct SendRecieve {
        string action;
        uint amount;
        string message;
        address otherPartyAddress;
        string otherPartyName;
    }
    // 3.to keep tract of the users name
    struct username {
        string name;
        bool hasName;
    }

    //Mapping from addresss to structs
    mapping(address => username) names;
    mapping(address => request[]) requests;
    mapping(address => SendRecieve[]) history;

    // function to enter the name to wallet address
    function addName(string memory _names) public {
        username storage newuser = names[msg.sender];
        newuser.name = _names;
        newuser.hasName = true;
    }

    //to create request
    function createRequest(
        address user,
        uint _amount,
        string memory _message
    ) public {
        request memory newRequest;
        newRequest.requestor = msg.sender;
        newRequest.amount = _amount;
        newRequest.message = _message;
        if (names[msg.sender].hasName) {
            newRequest.name = names[msg.sender].name;
        }
        requests[user].push(newRequest);
    }

    // to pay the request
    function payRequest(uint256 _requestIndex) public payable {
        require(
            _requestIndex < requests[msg.sender].length,
            "no such request "
        );
        request[] storage myRequests = requests[msg.sender];
        request storage payableRequest = myRequests[_requestIndex];

        uint256 topay = payableRequest.amount * 1000000000000000000;
        // fetching amount from payableRequest
        require(msg.value == (topay), "pay correct amount");

        payable(payableRequest.requestor).transfer(msg.value);
        addHistory(
            msg.sender,
            payableRequest.requestor,
            payableRequest.amount,
            payableRequest.message
        );
        myRequests[_requestIndex] = myRequests[myRequests.length - 1];
        myRequests.pop();
    }

    //get all request sent to user
    function addHistory(
        address sender,
        address reciever,
        uint _amount,
        string memory _message
    ) private {
        SendRecieve memory newsend;
        newsend.action = "-";
        newsend.amount = _amount;
        newsend.message = _message;
        newsend.otherPartyAddress = reciever;
        if (names[msg.sender].hasName) {
            newsend.otherPartyName = names[msg.sender].name;
        }
        history[sender].push(newsend);

        SendRecieve memory newRecieve;
        newRecieve.action = "-";
        newRecieve.amount = _amount;
        newRecieve.message = _message;
        newRecieve.otherPartyAddress = sender;
        if (names[msg.sender].hasName) {
            newRecieve.otherPartyName = names[msg.sender].name;
        }
        history[reciever].push(newsend);
    }
}
