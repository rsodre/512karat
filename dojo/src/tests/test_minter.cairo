#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use starknet::testing;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // token
    use origami_token::tests::constants::{ZERO, OWNER, SPENDER, RECIPIENT, VALUE, TOKEN_ID, TOKEN_ID_2};

    // karat
    use karat::{
        systems::{minter::{minter, IMinterDispatcher, IMinterDispatcherTrait}},
        systems::{karat_token::{karat_token, IKaratTokenDispatcher, IKaratTokenDispatcherTrait}},
        models::seed::{Seed, SeedTrait},
    };

    use karat::tests::tester::{tester, tester::{ Systems }};

    #[test]
    #[should_panic(expected:('Initializable: is initialized','ENTRYPOINT_FAILED'))]
    fn test_is_initialized() {
        let sys: Systems = tester::spawn_systems();
        sys.karat.initialize("A", "B", "C");
    }

    #[test]
    #[should_panic(expected:('ERC721: caller is not minter','ENTRYPOINT_FAILED'))]
    fn test_not_minter() {
        let sys: Systems = tester::spawn_systems();
        // direct karat minting is not possible
        sys.karat.mint(RECIPIENT(), 1);
    }

    #[test]
    fn test_mint_ok() {
        let sys: Systems = tester::spawn_systems();
        assert(sys.karat.total_supply() == 0, 'supply = 0');
        // #1
        let token_id_1: u128 = sys.minter.mint(sys.karat.contract_address);
        let token_uri_1: ByteArray = sys.karat.token_uri(1);
        let seed_1: Seed = get!(sys.world, (token_id_1), Seed);
        assert(sys.karat.total_supply() == 1, 'supply = 1');
        assert(token_id_1 == 1, 'token_id_1');
        assert(seed_1.seed > 0, 'seed_1');
        assert(token_uri_1.len() > 3, 'token_uri_1');
        // println!("seed_1:{}", seed_1.seed);
        // println!("{}", token_uri_1);
        // #2
        tester::impersonate(RECIPIENT());
        let token_id_2: u128 = sys.minter.mint(sys.karat.contract_address);
        let token_uri_2 = sys.karat.token_uri(2);
        let seed_2: Seed = get!(sys.world, (token_id_2), Seed);
        assert(sys.karat.total_supply() == 2, 'supply = 2');
        assert(token_id_2 == 2, 'token_id_2');
        assert(seed_2.seed > 0, 'seed_2');
        assert(seed_2.seed != seed_1.seed, 'seed_2_1');
        assert(token_uri_2.len() > 3, 'token_uri_2');
        assert(token_uri_2 != token_uri_1, 'token_uri_2_1');
    }

    #[test]
    #[should_panic(expected:('KARAT: unavailable','ENTRYPOINT_FAILED'))]
    fn test_not_available() {
        let sys: Systems = tester::spawn_systems();
        sys.minter.set_available(sys.karat.contract_address, 0);
        // others cant
        tester::impersonate(RECIPIENT());
        sys.minter.mint(sys.karat.contract_address);
    }

    #[test]
    fn test_not_available_owner_can_mint() {
        let sys: Systems = tester::spawn_systems();
        sys.minter.set_available(sys.karat.contract_address, 0);
        // owner can mint
        sys.minter.mint(sys.karat.contract_address);
    }

    #[test]
    #[should_panic(expected:('KARAT: not owner','ENTRYPOINT_FAILED'))]
    fn test_set_available_not_owner() {
        let sys: Systems = tester::spawn_systems();
        tester::impersonate(RECIPIENT());
        sys.minter.set_available(sys.karat.contract_address, 1000);
    }

    #[test]
    #[should_panic(expected:('KARAT: dont be greedy!','ENTRYPOINT_FAILED'))]
    fn test_greedy1() {
        let sys: Systems = tester::spawn_systems();
        tester::impersonate(SPENDER());
        sys.minter.mint(sys.karat.contract_address);
        sys.minter.mint(sys.karat.contract_address);
    }

    #[test]
    #[should_panic(expected:('KARAT: dont be greedy!','ENTRYPOINT_FAILED'))]
    fn test_greedy2() {
        let sys: Systems = tester::spawn_systems();
        tester::impersonate(SPENDER());
        sys.minter.mint(sys.karat.contract_address);
        tester::impersonate(RECIPIENT());
        sys.minter.mint(sys.karat.contract_address);
        sys.minter.mint(sys.karat.contract_address);
    }
    #[test]
    #[should_panic(expected:('KARAT: dont be greedy!','ENTRYPOINT_FAILED'))]
    fn test_greedy3() {
        let sys: Systems = tester::spawn_systems();
        sys.minter.mint(sys.karat.contract_address);
        tester::impersonate(RECIPIENT());
        sys.minter.mint(sys.karat.contract_address);
        tester::impersonate(SPENDER());
        sys.minter.mint(sys.karat.contract_address);
        sys.minter.mint(sys.karat.contract_address);
    }

    #[test]
    fn test_available_supply_baseline() {
        let sys: Systems = tester::spawn_systems();
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
    #[should_panic(expected:('KARAT: unavailable','ENTRYPOINT_FAILED'))]
    fn test_available_supply_unavailable() {
        let sys: Systems = tester::spawn_systems();
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
        let sys: Systems = tester::spawn_systems();
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
    #[should_panic(expected:('KARAT: minted out','ENTRYPOINT_FAILED'))]
    fn test_mint_out() {
        let sys: Systems = tester::spawn_systems();
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

}
