// SPDX-License-Identifier: MIT

// Ham Pepes are 1000 based frogs living on the Ham Chain L3
// This contract uses the onchain renderer created by Deployer.eth, modified for this use
// All traits are stored onchain using a sprite sheet and all metadata are stored onchain using the renderer and traits contract
// created by @based-bren (Farcaster) in 2024


pragma solidity ^0.8.13;

import "auth/Owned.sol";
import "utils/ReentrancyGuard.sol";
import "utils/MerkleProofLib.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "utils/ERC721AQueryable.sol";
import "utils/IERC721A.sol";
import "utils/ERC721A.sol";
import "contracts/HamPepeRenderer.sol";
import "utils/ERC20.sol";

contract HamPepes is ERC721AQueryable, Owned, ReentrancyGuard {
  HamPepeRenderer renderer;

  event PaymentReceived (address from, uint256 amount);

  uint256 public MAX_SUPPLY = 1000;
  uint256 public MINT_COST = 20_000 ether;   // 20,000 HAM should be 10 dollars approx
  uint256 public MAX_FREE =1;
  bool public freePhaseActive = false;
  bool public whitelistPhaseActive = false;
  bool public publicPhaseActive = false;
  bytes32 public merkleRoot;
  address public HAM;

  mapping(uint256 => bytes32) public tokenIdToSeed;
  mapping(address => uint256) public freePepes;

  error InvalidProof();
  error OnlyOneFreeMint();
  error SoldOut();
  error MaxMintWouldBeExceeded();
  error AmountExceedsAvailableSupply();
  error AmountRequired();
  error InsufficientFunds();

  constructor(
    address _renderer,
    address _HAM,
    bytes32 _merkleRoot)
    ERC721A("Ham Pepes", "HPEPE") Owned(msg.sender) {
    merkleRoot = _merkleRoot;
    HAM = _HAM;
    renderer = HamPepeRenderer(_renderer);
    }

// public funtion to set the merkle root at deployment

  function updateHAM(address _HAM) public onlyOwner {
    HAM = _HAM;
  }

  function withdrawErc20(address token, address to) public onlyOwner {
    ERC20(token).transfer(to, ERC20(token).balanceOf(address(this)));
  }

   function updateMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
   merkleRoot = _merkleRoot;
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

    function freeMint(uint256 amount, bytes32 [] calldata proof)
    public 
    nonReentrant
    {
        require(freePhaseActive = true);
        require(freePepes[msg.sender] + amount <= MAX_FREE, "only one free Pepe");

        bytes32 leaf = keccak256(abi.encode(msg.sender));

      if (!MerkleProofLib.verify(proof, merkleRoot, leaf)) {
        revert InvalidProof();
       }
       
    
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
    
    }

/// whitelist mint function required here with a check loop to search for holders of Ham Punks and The Ham LP
/// for now I will skip the WL mint and concentrate on free and public

/// public mint function

    function publicMint(uint256 amount) 
    public 
    payable 
    nonReentrant
    {
        require(publicPhaseActive = true);

    if(amountMinted[msg.sender] + amount > 4) {
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
    if (ERC20(HAM).balanceOf(msg.sender) < totalCost) {
      revert InsufficientFunds();
    }
    ERC20(HAM).transferFrom(
      msg.sender,
      0x000000000000000000000000000000000000dEaD, /// change this to a real address to receive some funds
      totalCost
    );

    uint256 current = _nextTokenId();
    uint256 end = current + amount - 1;

    for (; current <= end; current++) {
      tokenIdToSeed[current] = keccak256(
        abi.encodePacked(blockhash(block.number - 1), current)
      );
    }
    _mint(msg.sender, amount);
  }



/// admin panel

    function toggleFreeMinting() external onlyOwner {
        freePhaseActive = !freePhaseActive;
    }

    function toggleWLMinting() external onlyOwner {
        whitelistPhaseActive = !whitelistPhaseActive;

    }

    function togglePublicMinting() external onlyOwner {
        publicPhaseActive = !publicPhaseActive;

    }

    // withdraw the ether from the contract  

    function withdraw() external onlyOwner nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
     }
}