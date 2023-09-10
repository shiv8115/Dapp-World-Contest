// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TeamWallet {
    address public owner;

    bool private flag;
    uint256 private totalCredits;
    address[] private teamMembers;

    struct TransactionRequest {
        address sender;
        uint256 amount;
        uint256 approvals;
        uint256 rejections;
        bool executed;
        bool failed;
    }

    TransactionRequest[] private transactionRequests;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier onlyTeamMember() {
        require(isTeamMember(msg.sender), "You are not a team member");
        _;
    }

    modifier onlyIfNotExecuted(uint256 n) {
        require(
            n < transactionRequests.length,
            "Invalid transaction request index"
        );
        require(
            !transactionRequests[n].executed,
            "Transaction request has already been executed"
        );
        _;
    }

    function isTeamMember(address member) private view returns (bool) {
        for (uint256 i = 0; i < teamMembers.length; i++) {
            if (teamMembers[i] == member) {
                return true;
            }
        }
        return false;
    }

    //For setting up the wallet
    function setWallet(address[] memory members, uint256 credtis)
        public
        onlyOwner
    {
        require(!flag, "Function can only be executed once");
        require(members.length > 0, "At least one member is required");
        require(credtis > 0, "Credits must be greater than zero");
        for (uint256 i = 0; i < members.length; i++) {
            if (members[i] == owner) {
                revert("Owner cannot be a team member");
            }
        }
        flag = true;
        totalCredits = credtis;
        teamMembers = members;
    }

    //For spending amount from the wallet
    function spend(uint256 amount) public onlyTeamMember {
        require(amount > 0, "Amount should be greater than zero");
        bool fail = amount > totalCredits ? true : false;
        if (teamMembers.length == 1) {
            if (!fail) {
                totalCredits = totalCredits - amount;
                transactionRequests.push(
                    TransactionRequest(msg.sender, amount, 1, 0, true, false)
                );
            } else {
                transactionRequests.push(
                    TransactionRequest(msg.sender, amount, 1, 0, false, true)
                );
            }
        } else {
            transactionRequests.push(
                TransactionRequest(msg.sender, amount, 1, 0, false, fail)
            );
        }
    }

    //For approving a transaction request
    function approve(uint256 n) public onlyTeamMember onlyIfNotExecuted(n - 1) {
        require(
            transactionRequests[n - 1].sender != msg.sender,
            "Sender cannot approve"
        );
        require(
            !transactionRequests[n - 1].failed,
            "transaction already failed"
        );
        transactionRequests[n - 1].approvals++;

        if (
            transactionRequests[n - 1].approvals >=
            ((teamMembers.length * 70) / 100)
        ) {
            transactionRequests[n - 1].executed = true;
            totalCredits -= transactionRequests[n - 1].amount;
        }
    }

    //For rejecting a transaction request
    function reject(uint256 n) public onlyTeamMember onlyIfNotExecuted(n - 1) {
        require(
            !transactionRequests[n - 1].failed,
            "transaction already failed"
        );
        require(
            transactionRequests[n - 1].sender != msg.sender,
            "spender not reject transaction"
        );
        transactionRequests[n - 1].rejections++;

        if (
            transactionRequests[n - 1].rejections >
            ((teamMembers.length * 30) / 100)
        ) {
            transactionRequests[n - 1].failed = true;
        }
    }

    //For checking remaing credits in the wallet
    function credits() public view onlyTeamMember returns (uint256) {
        return totalCredits;
    }

    //For checking nth transaction status
    function viewTransaction(uint256 n)
        public
        view
        onlyTeamMember
        returns (uint256, string memory)
    {
        n = n - 1;
        require(
            n < transactionRequests.length,
            "Invalid transaction request index"
        );
        TransactionRequest memory request = transactionRequests[n];

        if (request.executed) {
            return (request.amount, "debited");
        } else if (request.failed) {
            return (request.amount, "failed");
        } else {
            return (request.amount, "pending");
        }
    }
}
