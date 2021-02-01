// SPDX-License-Identifier: MIT
pragma solidity >=0.6.6 <0.8.0;

contract Casino {
    uint16 private gamblersLimit;
    uint256 private totalSum;
    address private owner; //address is address of wallet 0x4b33b35b353b34b
    address[] private gamblers;
    address payable[] private winners;
    mapping (address => uint256) private gambles;
    bool isBetEven;
    
    //event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    
    constructor() {
        //msg.sender is the address of the sender of the current call
        owner = msg.sender;
        emit OwnerSet(address(0), owner);
        totalSum = 0;
        gamblersLimit = 30;
    }
    
    function getMyBalance() external view returns(uint256) {
        return gambles[msg.sender];
    }
    
    function getNumberOfGamblers() external view returns(uint256) {
        return gamblers.length;
    }
    
    function getTotalSum() external view returns(uint256) {
        return totalSum;
    }
    
    function bet() public payable {
        require(gamblers.length < gamblersLimit, "Gamblers limit was reached");
        
        address sender = msg.sender;
        uint256 value = msg.value;
        
        if(gambles[sender] > 0) {
            gambles[sender] += value;
        }
        else {
            gambles[sender] += value;
            gamblers.push(sender);
        }
        
        totalSum += value;
        
        if(gamblers.length == gamblersLimit) {
            executeGambleReturns();
        }
    }
    
    function getTime() public view returns(uint256) {
        return block.timestamp;
    }
    
    function executeGambleReturns() private {
        if((totalSum + block.timestamp) % 2 == 0) {
            isBetEven = true;
        } 
        
        uint256 winSum = 0;
        uint256 amountToGet = 0;
        
        for(uint16 i=0; i<gamblers.length; i++) {
            uint256 temp = gambles[gamblers[i]];
            
            if(temp % 2 == 0 && isBetEven){
                winners.push(payable(gamblers[i]));
            }
            else if(temp % 2 != 0 && !(isBetEven)){
                winners.push(payable(gamblers[i]));
            } else {
                winSum += temp;
            }
        }
        
        amountToGet = winSum / winners.length;
        
        for(uint i=0; i<winners.length; i++) {
            winners[i].transfer(amountToGet + gambles[winners[i]]);
        }
        
        resetState();
    }

    function resetState() private{
        gamblersLimit = 30;
        totalSum = 0;
        isBetEven = false;
        
        for(uint16 i=0; i<gamblers.length; i++) {
            gambles[gamblers[i]] = 0;
        }
        
        delete gamblers;
        delete winners;
    }
    
    function changeLimit(uint16 newLimit) external isOwner{
        gamblersLimit = newLimit;
    }
    
    function getLimit() external view returns(uint16) {
        return gamblersLimit;
    }
    
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }
    
    function getOwner() external view returns(address) {
        return owner;
    }
    
    
    
    
    
    
    
    
}