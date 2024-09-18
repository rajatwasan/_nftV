// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract VerityToken is ERC721, ERC721Enumerable, ERC721Pausable, Ownable, ERC721Burnable, ReentrancyGuard {
    uint256 private _nextTokenId;

    uint256 public constant MAX_SUPPLY = 100000000;
    uint256 public currentPrice;
    IERC20 public immutable stablecoin;

    string public baseTokenURI;
    uint256 public totalSold;

    event PriceUpdated(uint256 newPrice);
    event BaseURIUpdated(string newBaseURI);
    event TokenMinted(address indexed recipient, uint256 tokenId);
    event BatchMinted(address indexed recipient, uint256 quantity, uint256 firstTokenId);
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _baseTokenURI,
        uint256 initialPrice,
        address stablecoinAddress)
        ERC721(_name, _symbol)
        Ownable(msg.sender)
    {
        baseTokenURI = _baseTokenURI;
        currentPrice = initialPrice;
        stablecoin = IERC20(stablecoinAddress);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseTokenURI = _newBaseURI;
        emit BaseURIUpdated(_newBaseURI);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function safeMint() external onlyOwner {
        require(_nextTokenId < MAX_SUPPLY, "Max supply reached");
        uint256 newTokenId = _nextTokenId++;
        _safeMint(msg.sender, newTokenId);
        emit TokenMinted(msg.sender, newTokenId);
    }

    function safeMintBatch(uint256 quantity) external nonReentrant onlyOwner {
        require(_nextTokenId + quantity <= MAX_SUPPLY, "Exceeds max supply");
        uint256 firstTokenId = _nextTokenId;
        for (uint256 i = 0; i < quantity;) {
            uint256 newTokenId = _nextTokenId++;
            _safeMint(msg.sender, newTokenId);
            unchecked { ++i; }
        }
        totalSold += quantity;
        emit BatchMinted(msg.sender, quantity, firstTokenId);
    }

    function mint() public nonReentrant whenNotPaused {
        require(_nextTokenId < MAX_SUPPLY, "Max supply reached");
        require(stablecoin.balanceOf(msg.sender) >= currentPrice, "Insufficient stablecoin balance");
        require(stablecoin.allowance(msg.sender, address(this)) >= currentPrice, "Insufficient allowance");

        require(stablecoin.transferFrom(msg.sender, owner(), currentPrice), "Stablecoin transfer failed");

        uint256 newTokenId = _nextTokenId++;
        _safeMint(msg.sender, newTokenId);
        totalSold++;
        emit TokenMinted(msg.sender, newTokenId);
    }

    function mintBatch(uint256 quantity) public nonReentrant whenNotPaused {
        require(_nextTokenId + quantity <= MAX_SUPPLY, "Exceeds max supply");
        uint256 totalCost = currentPrice * quantity;
        require(stablecoin.balanceOf(msg.sender) >= totalCost, "Insufficient stablecoin balance");
        require(stablecoin.allowance(msg.sender, address(this)) >= totalCost, "Insufficient allowance");

        require(stablecoin.transferFrom(msg.sender, owner(), totalCost), "Stablecoin transfer failed");

        uint256 firstTokenId = _nextTokenId;
        for (uint256 i = 0; i < quantity;) {
            uint256 newTokenId = _nextTokenId++;
            _safeMint(msg.sender, newTokenId);
            unchecked { ++i; }
        }
        totalSold += quantity;
        emit BatchMinted(msg.sender, quantity, firstTokenId);
    }

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable, ERC721Pausable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._increaseBalance(account, value);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        currentPrice = newPrice;
        emit PriceUpdated(newPrice);
    }

    function getTotalSold() public view returns (uint256) {
        return totalSold;
    }
}