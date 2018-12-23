
contract ERC721 {
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}


contract CardBase {
 

  event Transfer(address from, address to, uint256 tokenId);
  event Auction(address owner, uint32 class, uint256 attribute, uint32 timeBlock);
  event Create(address owner, uint32 class, uint256 attribute);
  event Dead(address owner, uint256 tokenId);
  event Attack(uint256 tokenId1,uint256 tokenId2);
  event AttackSuccess(uint256 tokenId1,uint256 tokenId2);
  event AttackFail(uint256 tokenId1,uint256 tokenId2);

    struct Card{
      uint256 _tokenId;
      uint32 _class;
      uint256 _attribute;
      uint32 life;
      address owner;
    }
    Card[] Cards;
    uint128 public constant totalCards = uint128(708100);
    uint256 public LuckyFee = 5 finney;
    uint128 public countCards;
    uint32[5] public CardClass = [
        uint32(100),
        uint32(8000),
        uint32(50000),
        uint32(300000),
        uint32(350000)
    ];
    uint32[5] public CurrentClass ;

    mapping (uint256 => address) public CardIndexToOwner;
    mapping (address => uint256) ownershipTokenCount;
    mapping (uint256 => address) public CardIndexToApproved;

    ClockAuction public saleAuction;
    function setSaleAuctionAddress(address _address) {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        saleAuction = candidateContract;
    }

    function attack(uint256 _from, uint256 _to)returns(bool){
      Card card1 = Cards[_from];
      Card card2 = Cards[_to];
      require(card1.owner==msg.sender);
      Attack(_from, _to);
        if(compare(card1._class,card2._class)){
          card2.life--;
          AttackSuccess(_from,_to);
          if(card2.life==0){
            dead(card2.owner,_to);
            
            
          }return true;
        }
        else{
          card1.life--;
          AttackFail(_from,_to);
          if(card1.life==0){
            dead(card1.owner,_to);
            
            
          }return false;
        }

    }

    function dead(address owner, uint256 _tokenId){
      Dead(owner,_tokenId);
      Cards[_tokenId].owner=address(0);
      CurrentClass[Cards[_tokenId]._class]--;
      ownershipTokenCount[owner]--;
      delete CardIndexToApproved[_tokenId];
    }

    uint256 constant private FACTOR =  1157920892373161954235709850086879078532699846656405640394575840079131296399;

    function rand() public  view returns(uint256) {
      uint256 factor = FACTOR * 100 / totalCards;

      uint256 lastBlockNumber = block.number - 1;

      uint256 hashVal = uint256(block.blockhash(lastBlockNumber));

      return uint256((uint256(hashVal) / factor)) ;
    }
    function compare(uint256 _from,uint256 _to)view returns(bool){
      uint32 ran = uint32(rand()%10);
      if(_from-_to>1)
        return true;
      if(_to-_from>1)
        return false;
      if(_from-_to==1)
      {
	         if(ran==9)
	             return false;
	         else
	    return true;
      }
      if(_to-_from==1)
      {
	        if(ran==9)
	    return true;
	     else
	    return false;
      }
      if(_from==_to)
      {
	       if(ran>=0&&ran<=4)
	        return true;
          else
          return false;
        }
      }

    function GiftCard()payable returns(uint32){
          require(countCards<=totalCards);
         return _createCard(msg.sender);


    }
    function _createCard(address _owner)
        internal
        returns (uint32)
    {
        uint256 attribute=rand();
        uint256 rnum = rand()%totalCards;
        uint32 class;
        if(rnum<=100&&CurrentClass[0]<=CardClass[0])class=0;
        else if(rnum<=8100&&CurrentClass[1]<=CardClass[1])class=1;
        else if(rnum<=58100&&CurrentClass[2]<=CardClass[2])class=2;
        else if(rnum<=358100&&CurrentClass[3]<=CardClass[3])class=3;
        else {require(countCards<=totalCards);class=4;}
        CurrentClass[class]++;
        countCards++;

        Card memory _card = Card({
          _tokenId:0,
          _class:class,
          _attribute:attribute,
          life:5,
          owner:_owner
        });
        uint256 newCardId = Cards.push(_card) - 1;

        _card._tokenId=newCardId;
        require(newCardId == uint256(uint32(newCardId)));

       emit Create(
            _owner,
            class,
            attribute
        );

        _transfer(0, _owner, newCardId);

        return class;
    }





    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        ownershipTokenCount[_to]++;
        CardIndexToOwner[_tokenId] = _to;

        if (_from != address(0)) {
            Cards[_tokenId].owner=_to;
            ownershipTokenCount[_from]--;
            delete CardIndexToApproved[_tokenId];

        }
        Transfer(_from, _to, _tokenId);
    }
}

contract CardOwnership is CardBase, ERC721 {
    string public constant name = "CardGame";
    string public constant symbol = "CG";


    bytes4 constant InterfaceSignature_ERC165 =
        bytes4(keccak256('supportsInterface(bytes4)'));


    bytes4 constant InterfaceSignature_ERC721 =
        bytes4(keccak256('name()')) ^
        bytes4(keccak256('symbol()')) ^
        bytes4(keccak256('totalSupply()')) ^
        bytes4(keccak256('balanceOf(address)')) ^
        bytes4(keccak256('ownerOf(uint256)')) ^
        bytes4(keccak256('approve(address,uint256)')) ^
        bytes4(keccak256('transfer(address,uint256)')) ^
        bytes4(keccak256('transferFrom(address,address,uint256)')) ^
        bytes4(keccak256('tokensOfOwner(address)'));


        function CardOwnership() public {
           // _createCard(address(0));
        }


        function createSaleAuction(
          uint256 _cardId,
          uint256 _startingPrice,
          uint32 _step,
          uint32 _maxTimes
        )
            external
        {
            require(_owns(msg.sender, _cardId));
            _approve(_cardId, saleAuction);
            saleAuction.createAuction(
               _cardId,
               _startingPrice,
               _step,
               _maxTimes,
                msg.sender,
                0
            );
        }


          function bid(uint256 _tokenId,uint256 _bidAmount)
          external
          {
              saleAuction._bid(_tokenId, _bidAmount);
              saleAuction._transfer(msg.sender, _tokenId);
          }



    function supportsInterface(bytes4 _interfaceID) external view returns (bool)
    {
        return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    }
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return CardIndexToOwner[_tokenId] == _claimant;
    }
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return CardIndexToApproved[_tokenId] == _claimant;
    }
    function _approve(uint256 _tokenId, address _approved) internal {
        CardIndexToApproved[_tokenId] = _approved;
    }
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }
    function transfer(
        address _to,
        uint256 _tokenId
    )
        external
    {
        require(_to != address(0));
        require(_to != address(this));
        //require(_to != address(saleAuction));
        //require(_to != address(siringAuction));
      require(_owns(msg.sender, _tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }
    function approve(
        address _to,
        uint256 _tokenId
    )
        external
    {
        require(_owns(msg.sender, _tokenId));
        _approve(_tokenId, _to);

        // Emit approval event.
        Approval(msg.sender, _to, _tokenId);
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
    {
        require(_to != address(0));
        require(_to != address(this));
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));
        _transfer(_from, _to, _tokenId);
    }
    function totalSupply() public view returns (uint) {
        return Cards.length - 1;
    }

    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        owner = CardIndexToOwner[_tokenId];

        require(owner != address(0));
    }
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalCats = totalSupply();
            uint256 resultIndex = 0;

            uint256 catId;

            for (catId = 1; catId <= totalCats; catId++) {
                if (CardIndexToOwner[catId] == _owner) {
                    result[resultIndex] = catId;
                    resultIndex++;
                }
            }

            return result;
        }
    }


}


contract ClockAuctionBase {

    struct Auction {
        address seller;
        uint256 startingPrice;
        uint32 step;
        uint64 startedAt;
        uint32 maxTimes;
        address currentBuyer;
        uint256 currentHighestBid;
        uint32 times;
    }

    ERC721 public nonFungibleContract;

    uint256 public ownerCut;
    mapping (uint256 => Auction) tokenIdToAuction;

    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint32 step, uint32 maxTimes);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }
    function _escrow(address _owner, uint256 _tokenId) internal {
        nonFungibleContract.transferFrom(_owner, this, _tokenId);
    }
    function _transfer(address _receiver, uint256 _tokenId)  {
        nonFungibleContract.transfer(_receiver, _tokenId);
    }
    function _addAuction(uint256 _tokenId, Auction _auction) internal {


        tokenIdToAuction[_tokenId] = _auction;

        AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint32(_auction.step),
            uint32(_auction.maxTimes)
        );
    }
    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId);
        AuctionCancelled(_tokenId);
    }
    function _bid(uint256 _tokenId, uint256 _bidAmount)
    returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];

        uint256 price = auction.startingPrice;

        if(auction.times+1>= auction.maxTimes){
            address seller = auction.seller;
            _removeAuction(_tokenId);

            if (price > 0) {
                uint256 sellerProceeds = price ;


                seller.transfer(sellerProceeds);
                AuctionSuccessful(_tokenId, price, msg.sender);
            }


        }else{
            if(_bidAmount > auction.currentHighestBid+auction.step){
              auction.times++;
                tokenIdToAuction[_tokenId].currentHighestBid = _bidAmount;
                tokenIdToAuction[_tokenId].currentBuyer = msg.sender;
            }
        }
        require(_bidAmount > price);  //需要拍卖结束
        return price;
    }
    function _closeAuction(uint256 _tokenId, bool agreeDeal)public{
        Auction storage auction = tokenIdToAuction[_tokenId];

        require(msg.sender==auction.seller);

        if(agreeDeal){
            uint256 price = auction.currentHighestBid;
            if (price > 0) {
                uint256 auctioneerCut = _computeCut(price);
                uint256 sellerProceeds = price - auctioneerCut;
                auction.seller.transfer(sellerProceeds);
                AuctionSuccessful(_tokenId, price, auction.currentBuyer);
            }
        }
        _removeAuction(_tokenId);
    }
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }
    function _computeCut(uint256 _price) internal view returns (uint256) {
        return _price * ownerCut / 10000;
    }
}

contract ClockAuction is ClockAuctionBase {
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);
    function ClockAuction(address _nftAddress, uint256 _cut) public {
        require(_cut <= 10000);
        ownerCut = _cut;

        ERC721 candidateContract = ERC721(_nftAddress);
        nonFungibleContract = candidateContract;
    }
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint32 _step,
        uint32 _maxTimes,
        address _seller,
        uint256 currentHighestBid
    )
    external
    {
        require(_startingPrice == uint256(uint128(_startingPrice)));

        require(_owns(msg.sender, _tokenId));
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint32(_step),
            uint64(now),
            uint32(_maxTimes),
            _seller,
            0,
            0

        );
        _addAuction(_tokenId, auction);
    }
    function bid(uint256 _tokenId,uint256 _bidAmount)
    external
    {
        _bid(_tokenId, _bidAmount);
        _transfer(msg.sender, _tokenId);
    }
    function cancelAuction(uint256 _tokenId)
    external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }


    function getAuction(uint256 _tokenId)
    external
    view
    returns
    (
        address seller,
        uint256 startingPrice,
        uint32 step,
        uint64 startedAt,
        uint32 maxTimes,
        address currentBuyer,
        uint32 times,
        uint256 currentHighestBid
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
        auction.seller,
        auction.startingPrice,
        auction.step,
        auction.startedAt,
        auction.maxTimes,
        auction.currentBuyer,
        auction.times,
        auction.currentHighestBid
        );
    }

}

contract SaleClockAuction is ClockAuction {

    bool public isSaleClockAuction = true;


    function SaleClockAuction(address _nftAddr, uint256 _cut) public
    ClockAuction(_nftAddr, _cut) {}
      function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint32 _step,
        uint32 _maxTimes,
        address _seller,
        uint256 currentHighestBid
      )
      external
      {
          require(_startingPrice == uint256(uint128(_startingPrice)));

          require(msg.sender == address(nonFungibleContract));
          _escrow(_seller, _tokenId);
          Auction memory auction = Auction(
                _seller,
                uint128(_startingPrice),
                uint32(_step),
                uint64(now),
                uint32(_maxTimes),
                _seller,
                0,
                0
          );
          _addAuction(_tokenId, auction);
      }

      function bid(uint256 _tokenId)
      external
      payable
      {
          address seller = tokenIdToAuction[_tokenId].seller;
          uint256 price = _bid(_tokenId, msg.value);
          _transfer(msg.sender, _tokenId);
      }

      function closeAuction(bool agreed,uint256 tokenId) public{
          _closeAuction(tokenId,agreed);
      }

}
