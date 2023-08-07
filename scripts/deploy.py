from scripts.helpful_scripts import get_account
from brownie import NFTMarketplace, config


def deploy_nft_marketplace():
    account = get_account()
    nft_marketplace = NFTMarketplace.deploy(
        "Kangaroo Punks",
        "KP",
        "QmXAVG8w6VARwZ9NTxFqdWeHqGsxQAVSrPwceG19imkc1r",
        {"from": account},
    )
    print(f"Contract deployed to {nft_marketplace.address}")

    nft_token_id = 0
    if (
        nft_marketplace.ownerOf(nft_token_id)
        == "0x0000000000000000000000000000000000000000"
    ):
        print(f"NFT with token ID {nft_token_id} does not exist in the contract.")
        return

    nft_price = 0.1 * 10**18

    # Create a new NFT sale
    nft_marketplace.createSale(nft_token_id, nft_price, {"from": account})

    # Sale details
    sale_id = 1
    sale = nft_marketplace.getSale(sale_id)
    print("Sale details:")
    print(f"Seller: {sale[0]}")
    print(f"Token ID: {sale[1]}")
    print(f"Price: {sale[2]} wei")
    print(f"Active: {sale[3]}")

    # Buy the NFT if the sale exists
    if sale[3]:
        print("Buying the NFT...")
        nft_marketplace.buyNFT(sale_id, {"from": account, "value": nft_price})

        # Check the updated sales details
        sale = nft_marketplace.getSale(sale_id)
        print("Sale details after purchase:")
        print(f"Seller: {sale[0]}")
        print(f"Token ID: {sale[1]}")
        print(f"Price: {sale[2]} wei")
        print(f"Active: {sale[3]}")
    else:
        print("Sale does not exist or is not active.")
        return


def main():
    deploy_nft_marketplace()
