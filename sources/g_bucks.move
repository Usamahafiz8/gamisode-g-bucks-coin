module g_bucks::coin {
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self as tx_context, TxContext};
    use sui::object::{Self as sui_object, UID};
    
    /// The main struct representing the G-Bucks coin.
    struct COIN has drop {}

    /// The TransferCap struct is used to control and authorize the transfer of G-Bucks coins.
    struct TransferCap has key {
        id: UID,
    }

    /// Initializes the G-Bucks coin by creating the necessary capabilities
    /// and transferring them to the transaction sender.
    ///
    /// # Arguments
    /// * `witness` - A witness to create the G-Bucks coin.
    /// * `ctx` - The mutable reference to the transaction context.
    fun init(witness: COIN, ctx: &mut TxContext) {
        // Create the currency with the specified details and mint 1 unit initially.
        let (treasury_cap, metadata) = coin::create_currency<COIN>(
            witness,                               
            1,                                     
            b"G-Bucks",                            
            b"Gamisode Bucks",                     
            b"The Coins for the Gamisodes Platform", 
            option::none(),                        
            ctx                                    
        );

        // Create a TransferCap to authorize and control the transfer of G-Bucks.
        let transfer_cap = TransferCap {
            id: sui_object::new(ctx),        
        };
        
        // Grant the TransferCap to the transaction sender.
        transfer::transfer(transfer_cap, tx_context::sender(ctx));

        // Freeze the metadata to prevent further changes.
        transfer::public_freeze_object(metadata);
        
        // Transfer the TreasuryCap to the transaction sender.
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    }

    /// Mints a specified amount of G-Bucks and transfers them to a recipient.
    ///
    /// # Arguments
    /// * `_transfer_cap` - The mutable reference to the TransferCap.
    /// * `treasury_cap` - The mutable reference to the TreasuryCap for COIN.
    /// * `amount` - The amount of G-Bucks to mint and transfer.
    /// * `recipient` - The recipient's address.
    /// * `ctx` - The mutable reference to the transaction context.
    public entry fun mint_and_transfer(
        _transfer_cap: &mut TransferCap,
        treasury_cap: &mut TreasuryCap<COIN>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        // Mint the specified amount of G-Bucks.
        let minted_coins = coin::mint(treasury_cap, amount, ctx);
        
        // Transfer the minted coins to the recipient.
        transfer::public_transfer(minted_coins, recipient);
    }

    /// Spends G-Bucks by burning the specified coin.
    ///
    /// # Arguments
    /// * `treasury_cap` - The mutable reference to the TreasuryCap for COIN.
    /// * `coin` - The coin to be spent (burned).
    /// * `_ctx` - The mutable reference to the transaction context (currently unused).
    public fun spend(
        treasury_cap: &mut TreasuryCap<COIN>,
        coin: Coin<COIN>,
        _ctx: &mut TxContext
    ) {
        // Burn the specified coin to spend it.
        coin::burn(treasury_cap, coin);
    }
}
