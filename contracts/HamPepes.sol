// SPDX-License-Identifier: MIT

// Ham Pepes are 1000 based frogs living on the Ham Chain L3
// This contract uses the onchain renderer created by Deployer.eth, modified for this use
// All traits are stored onchain using a sprite sheet and all metadata are stored onchain using the renderer and traits contract
// created by @based-bren (Farcaster) in 2024


pragma solidity ^0.8.13;

import "auth/Owned.sol";
import "utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "utils/ERC721AQueryable.sol";
import "utils/IERC721A.sol";
import "utils/ERC721A.sol";
import "contracts/HamPepeRenderer.sol";

contract HamPepes is ERC721AQueryable, Owned, ReentrancyGuard {
  HamPepeRenderer renderer;

  event PaymentReceived (address from, uint256 amount);

  uint256 public MAX_SUPPLY = 1000;
  uint256 public Total_Supply = 0;
  uint256 public MINT_COST = 0.003 ether;   
  uint256 public MAX_FREE =1;
  bool public freePhaseActive = false;
  bool public whitelistPhaseActive = false;
  bool public publicPhaseActive = false;


  mapping(uint256 => bytes32) public tokenIdToSeed;
  mapping(address => uint256) public freePepes;

  /// Whitelist Settings

    mapping(address => bool) public whiteListed;

    /// Whitelist setup
    address public listController;

    modifier onlylistController() {
        require(msg.sender == listController, "Controller Only");
        _;
    }

  error OnlyOneFreeMint();
  error SoldOut();
  error MaxMintWouldBeExceeded();
  error AmountExceedsAvailableSupply();
  error AmountRequired();
  error InsufficientFunds();

  constructor(
    address _renderer)
    ERC721A("Ham Pepes", "HPEPE") Owned(msg.sender) {
    renderer = HamPepeRenderer(_renderer);
    listController = msg.sender;  // contract owner is the list controller
  
    }


// return the images for an array of token IDs

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721A, IERC721A)
    returns (string memory)
    {
    return renderer.getJsonUri(tokenId, tokenIdToSeed[tokenId]);  
    }

// set the first token ID to 1

    function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }



  mapping(address => uint) public amountMinted;

/// Free mint function
/// the variable freePepes is intended to check if the minter tries to mint more than MAX_FREE

    function freeMint(uint256 amount)
    public 
    nonReentrant
    {
        require(freePhaseActive = true, "Free mint phase is not active");
        require(whiteListed[msg.sender] == true, "Not on whitelist");
        require(freePepes[msg.sender] + amount <= MAX_FREE, "only one free Pepe");
       
    
     if (amount <= 0) {
      revert AmountRequired();
     }

    uint256 current = _nextTokenId();
    uint256 end = current + amount - 1;


    for (; current <= end; current++) {
      tokenIdToSeed[current] = keccak256(
        abi.encodePacked(blockhash(block.number - 1), current)
      );
    }
    freePepes[msg.sender] +=amount;
    _mint(msg.sender, amount);

    Total_Supply = Total_Supply + amount;
    }

/// Dev mint function

    function DevMint(uint256 amount) external onlyOwner nonReentrant
    {    
     if (amount <= 0) {
      revert AmountRequired();
     }

    uint256 current = _nextTokenId();
    uint256 end = current + amount - 1;


    for (; current <= end; current++) {
      tokenIdToSeed[current] = keccak256(
        abi.encodePacked(blockhash(block.number - 1), current)
      );
    }
    _mint(msg.sender, amount);
    

    Total_Supply = Total_Supply + amount;
    }




/// public mint function (ether)

    function publicMint(uint256 amount) 
    public 
    payable 
    nonReentrant
    {
        require(publicPhaseActive = true, "public mint phase is not active");

    if(amountMinted[msg.sender] + amount > 10) {
      revert MaxMintWouldBeExceeded();
    }
    amountMinted[msg.sender] += amount;
    uint256 totalMinted = _totalMinted();
    if (totalMinted == MAX_SUPPLY) {
      revert SoldOut();
    }

    if (amount <= 0) {
      revert AmountRequired();
    }
    uint256 totalAfterMint = totalMinted + amount;
    if (totalAfterMint > MAX_SUPPLY) {
      revert AmountExceedsAvailableSupply();
    }
    
    uint256 totalCost = amount * MINT_COST;
    if ((msg.value) < totalCost) {
      revert InsufficientFunds();
    }

    uint256 current = _nextTokenId();
    uint256 end = current + amount - 1;

    for (; current <= end; current++) {
      tokenIdToSeed[current] = keccak256(
        abi.encodePacked(blockhash(block.number - 1), current)
      );
    }
    _mint(msg.sender, amount);

    Total_Supply = Total_Supply + amount;
  }



/// admin panel

    function toggleFreeMinting() external onlyOwner {
        freePhaseActive = !freePhaseActive;
    }

    function togglePublicMinting() external onlyOwner {
        publicPhaseActive = !publicPhaseActive;

    }

    // withdraw the ether from the contract  

    function withdraw() external onlyOwner nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
     }

    function addToWhiteList(address[] calldata addresses) external onlylistController nonReentrant {
        for (uint i = 0; i < addresses.length; i++) {
            whiteListed[addresses[i]] = true;
        }
    }

    function changelistController(address _address) external onlyOwner {
        listController = _address;
    }
}