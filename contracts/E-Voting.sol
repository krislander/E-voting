// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.8.0;

contract Election {
    struct Ballot {
        uint32 ballotId;
        mapping(uint32 => bytes32) candidateBallot;
    }
    
    struct Candidate {
        uint32 candidateId;
        string candidateName;
        string candidateParty;
        uint256 votesReceived;
    }

    struct Voter {
        address voterAddress;
        uint32 voterId;
        bool hasVoted;
    }

    address private owner;
    modifier isOwner {
        require(msg.sender == owner, "You are not the owner of the Election!");
        _;
    }

    mapping (uint32 => Candidate) public candidates;
    mapping (address => Voter) public voters;
    uint32 public candidatesCount;
    uint32 public votersCount;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    event AddCandidate(uint candidateId);
    event VoteInElection(uint256 indexed candidateId);
    
    constructor() {
        owner = msg.sender;
        emit OwnerSet(address(0), owner);
        addCandidate("Donald Trump", "Republicans");
        addCandidate("Joe Biden", "Democrats");
    }
    
    function getNumberOfCandidates() external view returns(uint32) {
        return candidatesCount;
    }
    
    function getVotersCount() external view returns(uint32) {
        return votersCount;
    }
    
    function getCandidate(uint32 candidateId) public view returns(uint256, string memory, string memory, uint256) {
        return (candidateId, candidates[candidateId].candidateName, candidates[candidateId].candidateParty, candidates[candidateId].votesReceived);
    }

    function getTotalVotes(uint32 candidateId) view public returns (uint256) {
        bytes memory nameString = bytes(candidates[candidateId].candidateName);
        require(candidateId > 0 && nameString.length == 0, "Invalid candidate ID");
        return candidates[candidateId].votesReceived;
    }
    
    function addCandidate(string memory name, string memory party) isOwner public {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(candidatesCount, name, party, 0);
        emit AddCandidate(candidatesCount);
    }
    
    function vote(uint32 candidateId) public {
        // require(!voters[msg.sender], "Candidate has already voted!");
        require(candidateId > 0 && candidateId <= candidatesCount, "Invalid Candidate!");

        uint32 voterId = votersCount++;
        candidates[candidateId].votesReceived++;
        voters[msg.sender] = Voter(msg.sender, voterId, true);
        emit VoteInElection(candidateId);
    }
}