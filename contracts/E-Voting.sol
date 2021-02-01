// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.8.0;

contract Election {
    struct Ballot {
        uint32 ballotId;
        mapping(uint32 => bytes32) candidateBallot;
    }
    
    struct Candidate {
        uint256 candidateId;
        bytes32 candidateName;
        bytes32 candidateParty;
        uint256 votesReceived;
    }

    
    struct Voter {
        address voterAddress;
    }
    
    mapping (uint32 => Candidate) private candidates;
    mapping (uint256 => Voter) private voters;
    uint32 private candidatesCount;
    uint32 private votersCount;
    
    event VoteInElection(uint256 indexed candidateId);
    
    function getNumberOfCandidates() external view returns(uint32) {
        return candidatesCount;
    }
    
    function getVotersCount() external view returns(uint32) {
        return votersCount;
    }
    
    function getCandidate(uint32 candidateId) public view returns(uint256, bytes32, bytes32, uint256) {
        return (candidateId, candidates[candidateId].candidateName, candidates[candidateId].candidateParty, candidates[candidateId].votesReceived);
    }
    
    function addCandidate(bytes32 name, bytes32 party) private {
        candidates[candidatesCount] = Candidate(candidatesCount + 1, name, party, 0);
        candidatesCount++;
    }
    
    function vote(uint256 candidateId) public {
        
    }
}