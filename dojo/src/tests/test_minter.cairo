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
        models::{position::{Position, Vec2, position}, moves::{Moves, Direction, moves}}
    };
    use karat::tests::tester::{tester, tester::{ Systems }};


    #[test]
    #[available_gas(30000000)]
    fn test_mint() {
        let sys: Systems = tester::spawn_systems(false);

        sys.karat.initializer("KARAT", "512KARAT", "_uri_");
        assert(sys.karat.total_supply() == 0, 'supply = 0');

        sys.karat.mint(RECIPIENT(), 1);
        assert(sys.karat.total_supply() == 1, 'supply = 1');
        assert(sys.karat.token_uri(1) == "_uri_-1", 'token_uri');
    }
}
