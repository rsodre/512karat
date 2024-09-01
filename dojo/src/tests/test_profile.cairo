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
    #[available_gas(10__000_000_000)]
    fn test_profile_mint() {
        let sys: Systems = tester::spawn_systems();
        sys.minter.mint(sys.karat.contract_address);
    }

    #[test]
    #[available_gas(10__000_000_000)]
    fn test_profile_token_uri() {
        let sys: Systems = tester::spawn_systems();
        sys.minter.mint(sys.karat.contract_address);
        sys.karat.token_uri(1);
    }

}
