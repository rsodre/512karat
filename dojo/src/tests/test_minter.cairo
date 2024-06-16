#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use starknet::testing;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // token
    use token::tests::constants::{ZERO, OWNER, SPENDER, RECIPIENT, VALUE, TOKEN_ID, TOKEN_ID_2};

    // karat
    use karat::{
        systems::{minter::{minter, IMinterDispatcher, IMinterDispatcherTrait}},
        systems::{karat_token::{karat_token, IKaratTokenDispatcher, IKaratTokenDispatcherTrait}},
    };
    use karat::tests::tester::{tester, tester::{ Systems }};

    #[test]
    #[available_gas(100_000_000)]
    #[should_panic(expected:('Initializable: is initialized','ENTRYPOINT_FAILED'))]
    fn test_is_initialized() {
        let sys: Systems = tester::spawn_systems();
        sys.karat.initialize("A", "B", "C");
    }

    #[test]
    #[available_gas(100_000_000)]
    #[should_panic(expected:('ERC721: caller is not minter','ENTRYPOINT_FAILED'))]
    fn test_not_minter() {
        let sys: Systems = tester::spawn_systems();
        // direct karat minting is not possible
        sys.karat.mint(RECIPIENT(), 1);
    }

    #[test]
    #[available_gas(100_000_000)]
    fn test_mint_ok() {
        let sys: Systems = tester::spawn_systems();
        assert(sys.karat.total_supply() == 0, 'supply = 0');
        // #1
        sys.minter.mint(sys.karat.contract_address);
        let token_uri_1 = sys.karat.token_uri(1);
        assert(sys.karat.total_supply() == 1, 'supply = 1');
        assert(token_uri_1 != "", 'token_uri_1');
        // #2
        sys.minter.mint(sys.karat.contract_address);
        let token_uri_2 = sys.karat.token_uri(2);
        assert(sys.karat.total_supply() == 2, 'supply = 2');
        assert(token_uri_2 != "", 'token_uri_2');
        assert(token_uri_2 != token_uri_1, 'token_uri_2_1');
    }

    #[test]
    #[available_gas(100_000_000)]
    fn test_max_supply() {
        let sys: Systems = tester::spawn_systems();
        let mut supply: u128 = 0;
        loop {
            if (supply == sys.max_supply) {
                break;
            }
            sys.minter.mint(sys.karat.contract_address);
            supply += 1;
        };
    }

    #[test]
    #[available_gas(100_000_000)]
    #[should_panic(expected:('KARAT: minted out','ENTRYPOINT_FAILED'))]
    fn test_mint_out() {
        let sys: Systems = tester::spawn_systems();
        let mut supply: u128 = 0;
        loop {
            if (supply > sys.max_supply) {
                break;
            }
            sys.minter.mint(sys.karat.contract_address);
            supply += 1;
        };
    }
}
