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
        sys.minter.mint(sys.karat.contract_address);
        assert(sys.karat.total_supply() == 1, 'supply = 1');
// sys.karat.token_uri(1).print();
        assert(sys.karat.token_uri(1) == "/1", 'token_uri');
    }
}
