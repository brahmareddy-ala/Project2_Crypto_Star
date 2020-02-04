pragma solidity >=0.4.24;

import "../node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract StarNotary is ERC721 {
    string public name = "Udacity Star Notary";
    string public symbol = "USN";

    struct Star {
        string name;
    }

    mapping(uint256 => Star) public tokenIdToStarInfo; //token id => star info
    mapping(uint256 => uint256) public starsForSale; //token id==>price of star

    // Create Star using the Struct
    function createStar(string memory _name, uint256 _tokenId) public { // Passing the name and tokenId as a parameters
        Star memory newStar = Star(_name); // Star is an struct so we are creating a new Star
        tokenIdToStarInfo[_tokenId] = newStar; // Creating in memory the Star -> tokenId mapping
        _mint(msg.sender, _tokenId); // _mint assign the the star with _tokenId to the sender address (ownership)
    }

    modifier onlyOwner(uint256 _tokenId) {
        if(ownerOf(_tokenId) == msg.sender)
            _;
        else
            revert("You can't sale/transfer the Star you don't owned");
    }

    //Putting an Star for sale (Adding the star tokenid into the mapping starsForSale, first verify that the sender is the owner)
    function putStarUpForSale(uint256 _tokenId, uint256 _price) public onlyOwner(_tokenId) {
        starsForSale[_tokenId] = _price;
    }

    // Function that allows you to convert an address into a payable address
    function _make_payable(address x) internal pure returns (address payable) {
        return address(uint160(x));
    }

    function buyStar(uint256 _tokenId) public payable {
        require(starsForSale[_tokenId] > 0, "The Star should be up for sale");
        uint256 starCost = starsForSale[_tokenId];
        address ownerAddress = ownerOf(_tokenId);
        require(msg.value > starCost, "You need to have enough Ether");
        _transferFrom(ownerAddress, msg.sender, _tokenId); //We can't use _addTokenTo or_removeTokenFrom
        //functions, now we have to use _transferFrom
        address payable ownerAddressPayable = _make_payable(ownerAddress); // We need to make this conversion to be able to
        // use transfer() function to transfer ethers
        ownerAddressPayable.transfer(starCost);
        if(msg.value > starCost) {
            msg.sender.transfer(msg.value - starCost);
        }
    }

    // Implement Task 1 lookUptokenIdToStarInfo
    function lookUptokenIdToStarInfo(uint256 _tokenId) public view returns(string memory) {
        return tokenIdToStarInfo[_tokenId].name;
    }

    // Implement Task 1 Exchange Stars function
    function exchangeStars(uint256 _tokenId1, uint256 _tokenId2) public {
        require(ownerOf(_tokenId1) == msg.sender || ownerOf(_tokenId2) == msg.sender, "You can't exchange the Star you don't owned");
        address addr1 = ownerOf(_tokenId1);
        address addr2 = ownerOf(_tokenId2);
        _transferFrom(addr1, addr2, _tokenId1);
        _transferFrom(addr2, addr1, _tokenId2);
    }

    // Implement Task 1 Transfer Star function
    function transferStar(address _toUser, uint256 _tokenId) public onlyOwner(_tokenId) {
        _transferFrom(msg.sender, _toUser, _tokenId);
    }
}
