module g_bucks::coin {
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self as tx_context, TxContext};
    use sui::object::{Self as sui_object, UID};
    // use sui::token::{Self}
    
    // The main struct representing the G-Bucks coin.
    struct COIN has drop {}

    // The TransferCap struct is used to control and authorize the transfer of G-Bucks coins.
    struct TransferCap has key {
        id: UID,
    }


// token::newpolicy <transty cap> {token policy and } new_policy
// NEW POLICY FOR THE transfer  
// close loop token >>  new policy >> transfer policy actions ...

    // Initializes the G-Bucks coin, creates the necessary capabilities,
    // and transfers them to the transaction sender.
    fun init(witness: COIN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency<COIN>(
            witness,                               
            1,                                     
            b"G-Bucks",                            
            b"Gamisode Bucks",                     
            b"the Coins for the Gamisodes Platform", 
            option::none(),                        
            ctx                                    
        );

        let transfer_cap = TransferCap {
            id: sui_object::new(ctx),        
        };
        transfer ::transfer(transfer_cap,tx_context::sender(ctx)); // granting the ability to authorize and control the transfer of G-Bucks coins.
        transfer::public_freeze_object(metadata); // Freezing the metadata to prevent further changes
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx)); // Transferring the treasury capability to the transaction sender
    }

    // public entry fun mint(
    //     _transfer_cap: &mut TransferCap,
    //     treasury_cap: &mut TreasuryCap<COIN>, // The mutable reference to the treasury capability for COIN
        
    //     amount: u64,                          // The amount of G-Bucks to mint
    //     ctx: &mut TxContext                   // The transaction context
    // ) {
    //     let minted_coins = coin::mint(treasury_cap, amount, ctx);
    //     transfer::public_transfer(minted_coins, tx_context::sender(ctx));
    // }



    // public entry fun transfer(
    //     _transfer_cap: &mut TransferCap,
    //     coin: Coin<COIN>,
    //     recipient: address,
    //     ctx: &mut TxContext
    // ) {
    //     let owner_obj = tx_context::sender(ctx); // Retrieve the owner's address

    //     // Ensure that only the owner can call this function
    //     assert!(tx_context::sender(ctx) == owner_obj, 0x1);

    //     transfer::public_transfer(coin, recipient);
    // }

    public entry fun mint_and_transfer(
        _transfer_cap: &mut TransferCap,
        treasury_cap: &mut TreasuryCap<COIN>, // The mutable reference to the treasury capability for COIN
        amount: u64,                          // The amount to mint and transfer
        recipient: address,                   // The recipient's address
        ctx: &mut TxContext                   // The transaction context
    ) {
        let minted_coins = coin::mint(treasury_cap, amount, ctx);
        transfer::public_transfer(minted_coins, recipient);
    }




    /// Function to spend G-Bucks by destroying the coin
    public fun spend(
        treasury_cap: &mut TreasuryCap<COIN>,
        coin: Coin<COIN>,       // The coin to be spent
        _ctx: &mut TxContext     // The transaction context (currently unused)
    ) {
        // Destroy the coin (spend it)
        coin::burn(treasury_cap, coin);
    }
}
