#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use starknet::testing;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // token
    use origami_token::tests::constants::{ZERO, OWNER, OTHER};

    // karat
    use karat::{
        systems::{minter::{minter, IMinterDispatcher, IMinterDispatcherTrait}},
        systems::{karat_token::{karat_token, IKaratTokenDispatcher, IKaratTokenDispatcherTrait}},
        models::config::{Config, ConfigTrait},
        models::seed::{Seed, SeedTrait},
        models::constants::{CONST},
    };

    use karat::tests::tester::{tester, tester::{ Systems }};

    #[test]
    fn test_is_initialized() {
        let sys: Systems = tester::spawn_systems();
        println!("NAME: {}", sys.karat.name());
        println!("SYMBOL: {}", sys.karat.symbol());
        assert(sys.karat.name() == CONST::const_string(CONST::TOKEN_NAME), 'name');
        assert(sys.karat.symbol() == CONST::const_string(CONST::TOKEN_SYMBOL), 'symbol');
    }

    #[test]
    fn test_token_uri() {
        let sys: Systems = tester::spawn_systems();
        sys.minter.mint(sys.karat.contract_address);
        let token_uri_1: ByteArray = sys.karat.token_uri(1);
        // println!("{}", token_uri_1);
        println!("token_uri_len:{}", token_uri_1.len());
    }

}
