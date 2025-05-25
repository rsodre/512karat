#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use starknet::{testing, ContractAddress};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // token
    use origami_token::tests::constants::{
        ZERO, OWNER, OTHER, SPENDER, RECIPIENT,
        TOKEN_ID, TOKEN_ID_2, VALUE,
    };

    // karat
    use karat::{
        systems::{minter::{minter, IMinterDispatcher, IMinterDispatcherTrait}},
        systems::{karat_token::{karat_token, IKaratTokenDispatcher, IKaratTokenDispatcherTrait}},
        models::config::{Config, ConfigTrait},
        models::seed::{Seed, SeedTrait},
        models::constants::{CONST},
        utils::misc::{WEI},
        tests::coin_mock::{ICoinMockDispatcher, ICoinMockDispatcherTrait},
    };

    use karat::tests::tester::{tester, tester::{ Systems }};

    #[test]
    fn test_mint_ok() {
        let sys: Systems = tester::spawn_systems(false);
        assert(sys.karat.total_supply() == 0, 'supply = 0');
        // #1
        tester::impersonate(SPENDER());
        let token_id_1: u128 = sys.minter.mint(sys.karat.contract_address);
        let token_uri_1: ByteArray = sys.karat.token_uri(1);
        let seed_1: Seed = get!(sys.world, (token_id_1), Seed);
        assert(sys.karat.total_supply() == 1, 'supply = 1');
        assert(token_id_1 == 1, 'token_id_1');
        assert(seed_1.seed > 0, 'seed_1');
        assert(token_uri_1.len() > 100, 'token_uri_1');
        assert(sys.karat.owner_of(token_id_1.into()) == SPENDER(), 'owner_of_1');
        // println!("seed:{}", seed_1.seed);
        // #2
        tester::impersonate(RECIPIENT());
        let token_id_2: u128 = sys.minter.mint(sys.karat.contract_address);
        let token_uri_2 = sys.karat.token_uri(2);
        let seed_2: Seed = get!(sys.world, (token_id_2), Seed);
        assert(sys.karat.total_supply() == 2, 'supply = 2');
        assert(token_id_2 == 2, 'token_id_2');
        assert(seed_2.seed > 0, 'seed_2');
        assert(seed_2.seed != seed_1.seed, 'seed_2_1');
        assert(token_uri_2.len() > 100, 'token_uri_2');
        assert(token_uri_2 != token_uri_1, 'token_uri_2_1');
        assert(sys.karat.owner_of(token_id_2.into()) == RECIPIENT(), 'owner_of_2');
    }

    #[test]
    fn test_mint_to() {
        let sys: Systems = tester::spawn_systems(false);
        assert(sys.karat.total_supply() == 0, 'supply = 0');
        // #1
        tester::impersonate(SPENDER());
        let token_id: u128 = sys.minter.mint_to(sys.karat.contract_address, RECIPIENT());
        assert(sys.karat.owner_of(token_id.into()) == RECIPIENT(), 'owner_of_2');
    }

    #[test]
    #[should_panic(expected:('KARAT: caller is not minter','ENTRYPOINT_FAILED'))]
    fn test_not_minter() {
        let sys: Systems = tester::spawn_systems(false);
        // direct karat minting is not possible
        sys.karat.mint(RECIPIENT(), 1);
    }

    #[test]
    #[should_panic(expected:('MINTER: unavailable','ENTRYPOINT_FAILED'))]
    fn test_not_available() {
        let sys: Systems = tester::spawn_systems(false);
        sys.minter.set_available(sys.karat.contract_address, 0);
        // others cant
        tester::impersonate(RECIPIENT());
        sys.minter.mint(sys.karat.contract_address);
    }

    #[test]
    fn test_not_available_owner_can_mint() {
        let sys: Systems = tester::spawn_systems(false);
        sys.minter.set_available(sys.karat.contract_address, 0);
        // owner can mint
        sys.minter.mint(sys.karat.contract_address);
    }

    #[test]
    #[should_panic(expected:('MINTER: caller is not owner','ENTRYPOINT_FAILED'))]
    fn test_admin_set_available_not_owner() {
        let sys: Systems = tester::spawn_systems(false);
        tester::impersonate(RECIPIENT());
        sys.minter.set_available(sys.karat.contract_address, 1000);
    }

    #[test]
    fn test_available_supply_baseline() {
        let sys: Systems = tester::spawn_systems(false);
        let mut supply: u128 = 0;
        loop {
            if (supply == sys.available_supply) {
                break;
            }
            tester::impersonate(if (supply % 2 == 0) {SPENDER()} else {RECIPIENT()});
            sys.minter.mint(sys.karat.contract_address);
            supply += 1;
        };
    }

    #[test]
    #[should_panic(expected:('MINTER: unavailable','ENTRYPOINT_FAILED'))]
    fn test_available_supply_unavailable() {
        let sys: Systems = tester::spawn_systems(false);
        let mut supply: u128 = 0;
        loop {
            if (supply > sys.available_supply) {
                break;
            }
            tester::impersonate(if (supply % 2 == 0) {SPENDER()} else {RECIPIENT()});
            sys.minter.mint(sys.karat.contract_address);
            supply += 1;
        };
    }

    #[test]
    fn test_max_supply_baseline() {
        let sys: Systems = tester::spawn_systems(false);
        sys.minter.set_available(sys.karat.contract_address, sys.max_supply);
        let mut supply: u128 = 0;
        loop {
            if (supply == sys.max_supply) {
                break;
            }
            tester::impersonate(if (supply % 2 == 0) {SPENDER()} else {RECIPIENT()});
            sys.minter.mint(sys.karat.contract_address);
            supply += 1;
        };
    }

    #[test]
    #[should_panic(expected:('MINTER: minted out','ENTRYPOINT_FAILED'))]
    fn test_mint_out() {
        let sys: Systems = tester::spawn_systems(false);
        sys.minter.set_available(sys.karat.contract_address, sys.max_supply);
        let mut supply: u128 = 0;
        loop {
            if (supply > sys.max_supply) {
                break;
            }
            tester::impersonate(if (supply % 2 == 0) {SPENDER()} else {RECIPIENT()});
            sys.minter.mint(sys.karat.contract_address);
            supply += 1;
        };
    }

    #[test]
    #[should_panic(expected:('MINTER: minted out','ENTRYPOINT_FAILED'))]
    fn test_available_supply_owner_mint_out() {
        let sys: Systems = tester::spawn_systems(false);
        let mut supply: u128 = 0;
        loop {
            if (supply > sys.max_supply) {
                break;
            }
            sys.minter.mint(sys.karat.contract_address);
            supply += 1;
        };
    }


    //---------------------------------------
    // cool down
    //

    #[test]
    #[should_panic(expected:('MINTER: cool down!','ENTRYPOINT_FAILED'))]
    fn test_cool_down_1() {
        let sys: Systems = tester::spawn_systems(false);
        tester::impersonate(SPENDER());
        sys.minter.mint(sys.karat.contract_address);
        sys.minter.mint(sys.karat.contract_address);
    }
    #[test]
    #[should_panic(expected:('MINTER: cool down!','ENTRYPOINT_FAILED'))]
    fn test_cool_down_2() {
        let sys: Systems = tester::spawn_systems(false);
        tester::impersonate(SPENDER());
        sys.minter.mint(sys.karat.contract_address);
        tester::impersonate(RECIPIENT());
        sys.minter.mint(sys.karat.contract_address);
        sys.minter.mint(sys.karat.contract_address);
    }
    #[test]
    #[should_panic(expected:('MINTER: cool down!','ENTRYPOINT_FAILED'))]
    fn test_cool_down_3() {
        let sys: Systems = tester::spawn_systems(false);
        tester::impersonate(SPENDER());
        sys.minter.mint(sys.karat.contract_address);
        sys.minter.mint_to(sys.karat.contract_address, RECIPIENT());
    }
    #[test]
    #[should_panic(expected:('MINTER: cool down!','ENTRYPOINT_FAILED'))]
    fn test_cool_down_4() {
        let sys: Systems = tester::spawn_systems(false);
        tester::impersonate(SPENDER());
        sys.minter.mint(sys.karat.contract_address);
        tester::impersonate(RECIPIENT());
        sys.minter.mint_to(sys.karat.contract_address, SPENDER());
    }

    #[test]
    fn test_cool_down_owner_can_mint() {
        let sys: Systems = tester::spawn_systems(false);
        sys.minter.mint(sys.karat.contract_address);
        sys.minter.mint(sys.karat.contract_address);
    }



    //---------------------------------------
    // purchase
    //

    const PRICE: u8 = 100;

    fn TREASURY() -> ContractAddress {(starknet::contract_address_const::<0x1234>())}

    fn _karat_init_purchase(sys: Systems) {
        sys.karat.karat_init();
        sys.minter.set_royalty(sys.karat.contract_address, TREASURY(), 0);
        sys.minter.set_purchase_price(sys.karat.contract_address, sys.coin.contract_address, PRICE);
    }

    fn _approve(sys: Systems, account: ContractAddress, amount_eth: u8, quantity: u8) {
        tester::impersonate(account);
        sys.coin.faucet();
        sys.coin.approve(sys.minter.contract_address,  WEI(amount_eth.into() * quantity.into()));
    }

    #[test]
    fn test_purchase_ok() {
        let sys: Systems = tester::spawn_systems(true);
        _karat_init_purchase(sys);
        _approve(sys, SPENDER(), PRICE, 1);
        // save balances...
        let balance_spender_before: u256 = sys.coin.balance_of(SPENDER());
        let balance_treasury_before: u256 = sys.coin.balance_of(TREASURY());
        // mint...
        sys.minter.mint(sys.karat.contract_address);
        // check balances...
        let balance_spender_after: u256 = sys.coin.balance_of(SPENDER());
        let balance_treasury_after: u256 = sys.coin.balance_of(TREASURY());
        assert(balance_spender_after == balance_spender_before - WEI(PRICE.into()), 'balance_spender_after');
        assert(balance_treasury_after == balance_treasury_before + WEI(PRICE.into()), 'balance_treasury_after');
    }

    #[test]
    fn test_purchase_multiple_ok() {
        let sys: Systems = tester::spawn_systems(true);
        _karat_init_purchase(sys);
        _approve(sys, SPENDER(), PRICE, 4);
        // mint...
        sys.minter.mint(sys.karat.contract_address);
        sys.minter.mint(sys.karat.contract_address);
        sys.minter.mint_to(sys.karat.contract_address, SPENDER());
        sys.minter.mint_to(sys.karat.contract_address, RECIPIENT());
    }

    #[test]
    fn test_purchase_to_ok() {
        let sys: Systems = tester::spawn_systems(true);
        _karat_init_purchase(sys);
        _approve(sys, SPENDER(), PRICE, 3);
        sys.minter.mint_to(sys.karat.contract_address, RECIPIENT());
        // can mint again...
        sys.minter.mint_to(sys.karat.contract_address, RECIPIENT());
        sys.minter.mint(sys.karat.contract_address);
    }

    #[test]
    #[should_panic(expected:('MINTER: insufficient allowance','ENTRYPOINT_FAILED'))]
    fn test_purchase_insufficient_allowance() {
        let sys: Systems = tester::spawn_systems(true);
        _karat_init_purchase(sys);
        _approve(sys, SPENDER(), PRICE-1, 1);
        sys.minter.mint(sys.karat.contract_address);
    }

    #[test]
    #[should_panic(expected:('MINTER: insufficient balance','ENTRYPOINT_FAILED'))]
    fn test_purchase_insufficient_balance() {
        let sys: Systems = tester::spawn_systems(true);
        _karat_init_purchase(sys);
        _approve(sys, SPENDER(), PRICE, 1);
        sys.coin.transfer(OTHER(), sys.coin.balance_of(SPENDER()));
        sys.minter.mint(sys.karat.contract_address);
    }

    #[test]
    #[should_panic(expected:('MINTER: invalid receiver','ENTRYPOINT_FAILED'))]
    fn test_purchase_invalid_receiver() {
        let sys: Systems = tester::spawn_systems(true);
        _karat_init_purchase(sys);
        sys.minter.set_royalty(sys.karat.contract_address, ZERO(), 0);
        _approve(sys, SPENDER(), PRICE, 1);
        sys.minter.mint(sys.karat.contract_address);
    }




    //---------------------------------------
    // admin
    //

    #[test]
    fn test_admin_set_purchase_price_ok() {
        let sys: Systems = tester::spawn_systems(false);
        tester::impersonate(OWNER());
        // initial state
        let config: Config = get!(sys.world, (sys.karat.contract_address), Config);
        assert(config.purchase_coin_address == ZERO(), 'purchase_coin_address_INIT');
        assert(config.purchase_price_eth == 0, 'purchase_price_eth_INIT');
        // config...
        sys.minter.set_purchase_price(sys.karat.contract_address, OTHER(), 222);
        let config: Config = get!(sys.world, (sys.karat.contract_address), Config);
        assert(config.purchase_coin_address == OTHER(), 'purchase_coin_address_AFTER');
        assert(config.purchase_price_eth == 222, 'purchase_price_eth_AFTER');
    }

    #[test]
    #[should_panic(expected:('MINTER: invalid token address','ENTRYPOINT_FAILED'))]
    fn test_admin_set_purchase_price_invalid_token() {
        let sys: Systems = tester::spawn_systems(false);
        sys.minter.set_purchase_price(sys.minter.contract_address, OTHER(), 255);
    }

    #[test]
    #[should_panic(expected:('MINTER: caller is not owner','ENTRYPOINT_FAILED'))]
    fn test_admin_set_purchase_price_not_owner() {
        let sys: Systems = tester::spawn_systems(false);
        tester::impersonate(OTHER());
        sys.minter.set_purchase_price(sys.karat.contract_address, OTHER(), 255);
    }

    #[test]
    fn test_admin_set_royalty_ok() {
        let sys: Systems = tester::spawn_systems(false);
        tester::impersonate(OWNER());
        // initial state
        let config: Config = get!(sys.world, (sys.karat.contract_address), Config);
        assert(config.royalty_receiver == ZERO(), 'royalty_receiver_INIT');
        assert(config.royalty_fraction == 0, 'royalty_fraction_INIT');
        // config...
        sys.minter.set_royalty(sys.karat.contract_address, RECIPIENT(), 111);
        let config: Config = get!(sys.world, (sys.karat.contract_address), Config);
        assert(config.royalty_receiver == RECIPIENT(), 'royalty_receiver_AFTER');
        assert(config.royalty_fraction == 111, 'royalty_fraction_AFTER');
    }

    #[test]
    #[should_panic(expected:('MINTER: invalid token address','ENTRYPOINT_FAILED'))]
    fn test_admin_set_royalty_invalid_token() {
        let sys: Systems = tester::spawn_systems(false);
        sys.minter.set_royalty(sys.minter.contract_address, OTHER(), 999);
    }

    #[test]
    #[should_panic(expected:('MINTER: caller is not owner','ENTRYPOINT_FAILED'))]
    fn test_admin_set_royalty_not_owner() {
        let sys: Systems = tester::spawn_systems(false);
        tester::impersonate(OTHER());
        sys.minter.set_royalty(sys.karat.contract_address, OTHER(), 999);
    }

}
