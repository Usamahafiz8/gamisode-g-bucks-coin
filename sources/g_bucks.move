module g_bucks::coin {
    use std::option;
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self as tx_context, TxContext};
    use sui::object::{Self as sui_object, UID};

    /// The main struct representing the G-Bucks coin.
    /// This struct serves as a marker for the G-Bucks token type.
    struct COIN has drop {}

    /// Struct to represent the Transfer Policy Capability.
    /// This struct includes the publisher's address to restrict token transfers.
    struct TransferPolicyCap has store, key {
        id: UID,
        publisher: address, // The address of the publisher who is authorized to transfer tokens.
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
            b"G-Bucks",               // The name of the coin.
            b"Gamisode Bucks",        // The symbol of the coin.
            b"The Coins for the Gamisodes Platform", // A description of the coin's purpose.
            option::none(),
            ctx
        );

        // Create a TransferPolicyCap and store the publisher's address.
        let transfer_cap = TransferPolicyCap {
            id: sui_object::new(ctx),
            publisher: tx_context::sender(ctx), // Store the transaction sender's address as the publisher.
        };

        // Transfer the TransferPolicyCap to the transaction sender, allowing them to control transfers.
        transfer::transfer(transfer_cap, tx_context::sender(ctx));

        // Freeze the metadata to prevent any further changes.
        transfer::public_freeze_object(metadata);

        // Transfer the TreasuryCap, which allows minting and burning, to the transaction sender.
        transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    }

    /// Mints a specified amount of G-Bucks and transfers them to a recipient.
    /// This function is restricted to be called only by the publisher (initial creator).
    ///
    /// # Arguments
    /// * `_transfer_cap` - The mutable reference to the TransferPolicyCap that controls transfer permissions.
    /// * `treasury_cap` - The mutable reference to the TreasuryCap for COIN, which allows minting.
    /// * `amount` - The amount of G-Bucks to mint and transfer.
    /// * `recipient` - The recipient's address to whom the minted coins will be transferred.
    /// * `ctx` - The mutable reference to the transaction context.
    public entry fun mint_and_transfer(
        _transfer_cap: &mut TransferPolicyCap,
        treasury_cap: &mut TreasuryCap<COIN>,
        amount: u64,
        recipient: address,
        ctx: &mut TxContext
    ) {
        // Ensure that only the publisher can execute this function by checking the sender's address.
        assert!(tx_context::sender(ctx) == _transfer_cap.publisher, 0x1);

        // Mint the specified amount of G-Bucks using the TreasuryCap.
        let minted_coins = coin::mint(treasury_cap, amount, ctx);

        // Transfer the minted coins to the specified recipient.
        transfer::public_transfer(minted_coins, recipient);
    }

/// General transfer function restricted to the publisher.
public entry fun transfer(
    _transfer_cap: &mut TransferPolicyCap,
    coin: Coin<COIN>,
    recipient: address,
    ctx: &mut TxContext
) {
    // Ensure that only the publisher can transfer the coins.
    assert!(tx_context::sender(ctx) == _transfer_cap.publisher, 0x1);

    // Transfer the coin to the specified recipient.
    transfer::public_transfer(coin, recipient);
}

    /// Spends G-Bucks by burning the specified coin.
    ///
    /// # Arguments
    /// * `treasury_cap` - The mutable reference to the TreasuryCap for COIN, which allows burning.
    /// * `coin` - The coin to be spent (burned).
    /// * `_ctx` - The mutable reference to the transaction context (currently unused).
    public fun spend(
        treasury_cap: &mut TreasuryCap<COIN>,
        coin: Coin<COIN>,
        _ctx: &mut TxContext
    ) {
        // Burn the specified coin to permanently remove it from circulation.
        coin::burn(treasury_cap, coin);
    }
}
