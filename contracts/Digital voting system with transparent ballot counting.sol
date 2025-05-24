// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title TransparentVoting
 * @dev A digital voting system with transparent ballot counting
 */
contract TransparentVoting {
    struct Proposal {
        string name;
        string description;
        uint256 voteCount;
    }
    
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint256 votedProposalId;
    }
    
    address public chairperson;
    Proposal[] public proposals;
    mapping(address => Voter) public voters;
    
    uint256 public startTime;
    uint256 public endTime;
    bool public votingEnded;
    
    event VoterRegistered(address indexed voter);
    event VoteCast(address indexed voter, uint256 proposalId);
    event VotingEnded(uint256 timestamp, Proposal[] finalResults);
    
    modifier onlyChairperson() {
        require(msg.sender == chairperson, "Only chairperson can call this function");
        _;
    }
    
    modifier votingOpen() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Voting is not currently open");
        require(!votingEnded, "Voting has already ended");
        _;
    }

    /**
     * @dev Default constructor with hardcoded proposals and voting time
     */
    constructor() {
        chairperson = msg.sender;

        // Set default proposals
        proposals.push(Proposal("Proposal A", "Description A", 0));
        proposals.push(Proposal("Proposal B", "Description B", 0));

        // Default voting time: starts in 1 minute, ends in 1 hour
        startTime = block.timestamp + 60;
        endTime = block.timestamp + 3600;

        // Register chairperson
        voters[chairperson].isRegistered = true;
    }
    
    /**
     * @dev Register a voter
     * @param voter Address of the voter to register
     */
    function registerVoter(address voter) public onlyChairperson {
        require(!voters[voter].isRegistered, "Voter is already registered");
        voters[voter].isRegistered = true;
        emit VoterRegistered(voter);
    }
    
    /**
     * @dev Cast a vote
     * @param proposalId ID of the proposal to vote for
     */
    function vote(uint256 proposalId) public votingOpen {
        Voter storage sender = voters[msg.sender];
        require(sender.isRegistered, "Not registered to vote");
        require(!sender.hasVoted, "Already voted");
        require(proposalId < proposals.length, "Invalid proposal ID");
        
        sender.hasVoted = true;
        sender.votedProposalId = proposalId;
        
        proposals[proposalId].voteCount += 1;
        
        emit VoteCast(msg.sender, proposalId);
    }
    
    /**
     * @dev End the voting and finalize results
     */
    function endVoting() public onlyChairperson {
        require(block.timestamp >= endTime || block.timestamp > startTime, "Voting period has not ended yet");
        require(!votingEnded, "Voting has already ended");
        
        votingEnded = true;
        emit VotingEnded(block.timestamp, proposals);
    }
    
    /**
     * @dev Get the number of proposals
     * @return The number of proposals
     */
    function getProposalCount() public view returns (uint256) {
        return proposals.length;
    }
}
