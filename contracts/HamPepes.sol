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
//  bytes32 public merkleRoot;

  uint256 public startTime;
  mapping (uint256 => bytes32) public tokenIdToSeed;

  error InsufficientFunds();
  error NotStarted();
  error AmountRequired();
  error SoldOut();
  error AmountExceedsAvailableSupply();
  error InvalidProof();
  error MaxMintWouldBeExceeded();
  error OnlyOneFreePepe();

  constructor(
  uint256 _startTime,
    address _renderer//,
    //bytes32 _merkleRoot
  ) ERC721A("Ham Pepes", "HPEPE") Owned(msg.sender) {
    startTime = _startTime;
    //merkleRoot = _merkleRoot;
    renderer = HamPepeRenderer(_renderer);
  }

//  function updateMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
//    merkleRoot = _merkleRoot;
//  }

  function updateStartTime(uint256 _startTime) public onlyOwner {
    startTime = _startTime;
 }


  /// @dev Get on-chain token URI
  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721A, IERC721A)
    returns (string memory)
  {
    return renderer.getJsonUri(tokenId, tokenIdToSeed[tokenId]);
  }

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  function isWlPhase() public view returns (bool) {
    return block.timestamp < startTime + 48 hours;
  }

  function withdraw() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

  mapping(address => uint) public amountMinted;

/// free mint function
/// 1 free mint per address on the whitelist

  function freeMint(uint256 amount) //bytes32[] calldata proof)
  public 
  nonReentrant
  {
    //if (isWlPhase()) {
    //  bytes32 leaf = keccak256(abi.encode(msg.sender));
    //  if (!MerkleProofLib.verify(proof, merkleRoot, leaf)) {
     //   revert InvalidProof();
    //  }
      if(amountMinted[msg.sender] + amount > 1) {
      revert OnlyOneFreePepe();
    }
    uint256 current = _nextTokenId();
    uint256 end = current + amount - 1;

    for (; current <= end; current++) {
      tokenIdToSeed[current] = keccak256(
        abi.encodePacked(blockhash(block.number - 1), current)
      );
    }
    _safeMint(msg.sender, amount);

  }
  
  /// Public mint function
  /// max mint per wallet is 4

  function publicMint(uint256 amount)
    public
    payable
    nonReentrant
  {
    if(amountMinted[msg.sender] + amount > 4) {
      revert MaxMintWouldBeExceeded();
    }
    amountMinted[msg.sender] += amount;
    uint256 totalMinted = _totalMinted();
    if (totalMinted == MAX_SUPPLY) {
      revert SoldOut();
    }
    if (block.timestamp < startTime) {
      revert NotStarted();
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
    _safeMint(msg.sender, amount);
  }
}

//  receive() external payable virtual {
//    emit PaymentReceived(msg.sender, msg.value);
//  }

//  fallback() external payable {
//    emit PaymentReceived(msg.sender, msg.value);
//  }