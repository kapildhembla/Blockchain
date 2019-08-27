pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract Lottery {
    
    enum UserType {Issuer,Investor}
    enum LotteryState {NotStarted, Started,Finished}
    
    LotteryState state;
    
    struct Player {
        address playerAddress;
        string playerName;
        string emailId;
        string phoneNumber;
        bool isExist;
    }
    
    struct LotteryTicket {
        uint lotteryId;
        uint price;
        address ticketOwner;
    }
    

    address private owner;
    uint32 private totalAmount;
    uint32 private ticketPrice;
    address private winner;
    
    mapping (address => Player) playerMap;
    Player[] players;
    LotteryTicket[] tickets;
    mapping(address => LotteryTicket[]) playerLotteryTicketsMapping;
    
    constructor () public {
        state = LotteryState.NotStarted;
        owner = msg.sender;
    }
    
    function registerPlayer(string memory _name, string memory _emailId, string memory  _phoneNumber) public {
        //Owner shouldn't be player
        require(owner != msg.sender);
        require((state != LotteryState.Started) && (state != LotteryState.Finished), "Player can't register while lottery has started or finished.");
        
        if(!playerMap[msg.sender].isExist ) {
            Player memory _player = Player(msg.sender, _name, _emailId, _phoneNumber,true);
            playerMap[msg.sender] = _player;
            players.push(_player);
        }
        // new event to be send to owner
    }
    
    function startLottery() public{
        require (owner == msg.sender, "Only owner can open lottery process.");
        ticketPrice = 1;
        state = LotteryState.Started;
        
    }
    
    function buyLotteryTicket() public {
        buyLotteryTickets(1);
        //event to be sendout to owner
    }
    
    function buyLotteryTickets(uint count) public {
        require(state == LotteryState.Started, "Lottery is not yet opened");
        require(owner != msg.sender, "Lottery owner/organizer can't buy tickets.");
        require(playerMap[msg.sender].isExist,"User not registered.");
        
        for(uint counter=1; counter <= count; counter++) {
            LotteryTicket memory ticket = LotteryTicket(tickets.length+1,ticketPrice, msg.sender);
            totalAmount = totalAmount + ticketPrice;
            tickets.push(ticket);
            playerLotteryTicketsMapping[msg.sender].push(ticket);
        }
        
        //event to be sendout to owner
    }
    
    function processLotteryWinners() public returns (Player memory _winner) {
        require(msg.sender == owner, "Only owner can execute ");
        require(state == LotteryState.Started, "Lottery is not yet opened");
        uint32 prizeMoney = totalAmount/2;
        /*uint32 firstPrizeMoney = prizeMoney * 50/100;
        uint32 secondPrizeMoney = prizeMoney * 30/100;
        uint32 thirdPrizeMondy = prizeMoney * 20/100;
        */
        //Randomly select the numbers
        
        uint randomNumber = uint(keccak256(abi.encodePacked(now,  tickets.length))) % tickets.length;
        LotteryTicket memory winnerTicket = tickets[randomNumber - 1];
        
        winner = winnerTicket.ticketOwner;
        
        //Send notification
        
        state = LotteryState.Finished;
        return playerMap[winner];
        
    }
    
    function getLotteryTickets() view public returns (LotteryTicket[] memory _tickets ) {
         require(msg.sender == owner, "Only owner can execute ");
         return(tickets);
    }
    
     function getPlayers() view public returns (Player[] memory _players ) {
         require(msg.sender == owner, "Only owner can execute ");
         return(players);
    }
    
    function getPurchasedLotteryTickets() view public returns (LotteryTicket[] memory _tickets) {
        require(msg.sender != owner, "Owner can't have tickets ");
       _tickets = playerLotteryTicketsMapping[msg.sender];
        
    }
    
    
}
