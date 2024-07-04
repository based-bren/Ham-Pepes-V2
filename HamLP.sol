// src/HamLP/HamLP.sol

contract HamLP is ERC721AQueryable, Owned, ReentrancyGuard {
  HamLPRenderer renderer;

  event PaymentReceived(address from, uint256 amount);

  uint256 public MAX_SUPPLY = 1000;
  uint256 public MINT_COST = 117_600 ether;
  address public TN100x;
  bytes32 public merkleRoot;

  uint256 public startTime;
  mapping(uint256 => bytes32) public tokenIdToSeed;

  error InsufficientFunds();
  error NotStarted();
  error AmountRequired();
  error SoldOut();
  error AmountExceedsAvailableSupply();
  error InvalidProof();
  error MaxMintWouldBeExceeded();

  constructor(
    string memory name,
    string memory symbol,
    uint256 _startTime,
    address _renderer,
    address _tn100x,
    bytes32 _merkleRoot
  ) ERC721A(name, symbol) Owned(msg.sender) {
    TN100x = _tn100x;
    startTime = _startTime;
    merkleRoot = _merkleRoot;
    renderer = HamLPRenderer(_renderer);
  }

  function updateTn100x(address _tn100x) public onlyOwner {
    TN100x = _tn100x;
  }

  function updateMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function withdrawErc20(address token, address to) public onlyOwner {
    ERC20(token).transfer(to, ERC20(token).balanceOf(address(this)));
  }

  function updateStartTime(uint256 _startTime) public onlyOwner {
    startTime = _startTime;
  }

  /// @dev Withdraw any ETH sent to the contract
  function withdrawEth(uint256 amount) public onlyOwner {
    Address.sendValue(payable(owner), amount);
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

  mapping(address => uint) public amountMinted;

  /// @dev Public mint function
  function mint(uint256 amount, bytes32[] calldata proof)
    public
    payable
    nonReentrant
  {
    if (isWlPhase()) {
      bytes32 leaf = keccak256(abi.encode(msg.sender));
      if (!MerkleProofLib.verify(proof, merkleRoot, leaf)) {
        revert InvalidProof();
      }
    }
    if(amountMinted[msg.sender] + amount > 2) {
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
    if (ERC20(TN100x).balanceOf(msg.sender) < totalCost) {
      revert InsufficientFunds();
    }
    ERC20(TN100x).transferFrom(
      msg.sender,
      0x000000000000000000000000000000000000dEaD,
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

  receive() external payable virtual {
    emit PaymentReceived(msg.sender, msg.value);
  }

  fallback() external payable {
    emit PaymentReceived(msg.sender, msg.value);
  }
}
