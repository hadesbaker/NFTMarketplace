// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721, Ownable {
    using Strings for uint256;

    // Store the base token URI for metadata (e.g., "https://opensea.io/collection/")
    string private _baseTokenURI;

    // Counter for generating unique sale IDs
    uint256 private _saleIdCounter;

    struct Sale {
        address seller;
        uint256 tokenId;
        uint256 price;
        bool active;
    }

    // Mapping from sale ID to Sale data
    mapping(uint256 => Sale) private _sales;

    event SaleCreated(uint256 saleId, address indexed seller, uint256 indexed tokenId, uint256 price);
    event SaleCancelled(uint256 saleId);
    event SaleSold(uint256 saleId, address indexed buyer, uint256 indexed tokenId, uint256 price);

    constructor(string memory name, string memory symbol, string memory baseTokenURI) ERC721(name, symbol) {
        _baseTokenURI = baseTokenURI;
    }

    // Mint an NFT and put it up for sale
    function createSale(uint256 tokenId, uint256 price) external {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT!");
        _saleIdCounter++;
        _sales[_saleIdCounter] = Sale({
            seller: msg.sender,
            tokenId: tokenId,
            price: price,
            active: true
        });
        emit SaleCreated(_saleIdCounter, msg.sender, tokenId, price);
    }

    // Cancel an existing sale
    function cancelSale(uint256 saleId) external {
        require(_sales[saleId].seller == msg.sender, "You can only cancel your own sale!");
        require(_sales[saleId].active, "Sale has already been canceled!");
        _sales[saleId].active = false;
        emit SaleCancelled(saleId);
    }

    // Buy an NFT that is up for sale
    function buyNFT(uint256 saleId) external payable {
        Sale memory sale = _sales[saleId];
        require(sale.active, "Sale in inactive!");
        require(msg.value >= sale.price, "Insufficient payment!");

        address seller = sale.seller;
        uint256 tokenId = sale.tokenId;
        uint256 price = sale.price;

        // Transferring ownership
        _transfer(seller, msg.sender, tokenId);
        sale.active = false;
        _sales[saleId] = sale;

        // Transferring payment
        (bool success, ) = seller.call{ value: price}("");
        require(success, "Payment failed!");

        emit SaleSold(saleId, msg.sender, tokenId, price);
    }

    // Custom tokenURI override
    function _baseURI() internal view returns (string memory) {
        return _baseTokenURI;
    }

}