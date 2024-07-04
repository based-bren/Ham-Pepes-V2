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

contract HamPepes is ERC721AQueryable, Owned, ReentrancyGuard {
  HamPepeRenderer renderer;

  event PaymentReceived (address from, uint256 amount);

  uint256 public MAX_SUPPLY = 1000;
  uint256 public MINT_COST = 0.005 ether;
  uint256 public MAX_FREE =379;
  bool public freePhaseActive = false;
  bool public whitelistPhaseActive = false;
  bool public publicPhaseActive = false;
  //bytes32 public merkleRoot;

  mapping(uint256 => bytes32) public tokenIdToSeed;

  error InvalidProof();
  error OnlyOneFreeMint();
  error SoldOut();
  error MaxMintWouldBeExceeded();
  error AmountExceedsAvailableSupply();
  error AmountRequired();
  error InsufficientFunds();

  constructor(
    address _renderer)
   // bytes32 _merkleRoot)
    ERC721A("Ham Pepes", "HPEPE") Owned(msg.sender) {
   // merkleRoot = _merkleRoot;
    renderer = HamPepeRenderer(_renderer);
    }

// public funtion to set the merkle root at deployment

   // function updateMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
   // merkleRoot = _merkleRoot;
   // }

// return the images for an array of token IDs

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721A, IERC721A)
    returns (string memory)
    {
    return renderer.getJsonUri(tokenId, tokenIdToSeed[tokenId]);  // create this function
    }

// set the first token ID to 1

    function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }



  mapping(address => uint) public amountMinted;

/// Free mint function

//    function freeMint(uint256 amount, bytes32 [] calldata proof)
//    public 
 //   nonReentrant
 //   {
 //       require(freePhaseActive = true);

 //       bytes32 leaf = keccak256(abi.encode(msg.sender));
     // if (!MerkleProofLib.verify(proof, merkleRoot, leaf)) {
     //   revert InvalidProof();
      //}
 ////      revert OnlyOneFreeMint();
//    }
  //  if (amount <= 0) {
  //    revert AmountRequired();
  //  }

 //   uint256 current = _nextTokenId();
 //   uint256 end = current + amount - 1;


 //   for (; current <= end; current++) {
  //    tokenIdToSeed[current] = keccak256(
  //      abi.encodePacked(blockhash(block.number - 1), current)
   //   );
  //  }
   // _mint(msg.sender, amount);
    
    //}

/// whitelist mint function required here with a check loop to search for holders of Ham Punks and The Ham LP

/// public mint function
/// there is no mint cost check in here yet

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
    if (msg.value < totalCost) {
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