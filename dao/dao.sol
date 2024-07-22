// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract Dao {
    
    struct user {
        bool isMember;
        uint lastPaid;
    }
    
    mapping (address => user) public addressToUser;

    enum Vote {
        yay,
        nay
    }

    struct Proposal {
        string description;
        address user;
        uint256 yayVotes;
        uint256 nayVotes;
        uint256 deadline;
        bool executed;
        mapping(address => bool) voted;
    }

    uint public numProposal;

    mapping (uint => Proposal) idToProposal;

    uint membership = 0.1 ether;
    uint premium = 1 ether;
    uint duration = 30 days;
    uint claimAmount = 100 ether;

    function join() public payable {
        require(msg.value == membership);
        addressToUser[msg.sender] = user(true, 0);
    }

    function payPremium() public payable {
        require(msg.value == premium, "value not equal to premium amount");
        require(addressToUser[msg.sender].lastPaid + duration < block.timestamp, "Can't pay yet, wait more");
        addressToUser[msg.sender].lastPaid = block.timestamp;
    }

    modifier onlyMember() {
        require(addressToUser[msg.sender].isMember == true, "not a member of pool");
        _;
    }

    function claimPropose(string memory _description) public onlyMember {
        numProposal ++;
        Proposal storage proposal = idToProposal[numProposal];
        proposal.deadline = block.timestamp + 3 days;
        proposal.description = _description;
        proposal.user = msg.sender;
    }

    function claimVoting(uint proposalId, Vote vote) public onlyMember {
        Proposal storage proposal = idToProposal[proposalId];
        require(idToProposal[proposalId].deadline > block.timestamp, "deadline exceeded");
        require(!proposal.voted[msg.sender], "already voted");
        if (vote == Vote.yay) {
            proposal.yayVotes++;
        }
        if (vote == Vote.nay) {
            proposal.nayVotes++;
        }
        proposal.voted[msg.sender] = true;
    }

    function claim(uint proposalId) public {
        Proposal storage proposal = idToProposal[proposalId];
        if(proposal.yayVotes > proposal.nayVotes) {
            payable(proposal.user).transfer(claimAmount);
        }
    }

    function poolAmount() public view returns (uint) {
        return address(this).balance;
    }

    receive() external payable {}

    fallback() external payable {}
}