use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use karat::{
    models::seed::{Seed, SeedTrait},
};

#[derive(Copy, Drop, Serde)]
// #[dojo::model]
struct TokenData {
    token_id: u128,
    seed: u128,
    trait_names: Span<ByteArray>,
    trait_values: Span<ByteArray>,
}

#[generate_trait]
impl TokenDataTraitImpl of TokenDataTrait {
    fn new(world: IWorldDispatcher, token_id: u128) -> TokenData {
        let seed: Seed = get!(world, (token_id), Seed);
        (TokenData{
            token_id,
            seed: seed.seed,
            trait_names: array!["Trait_1", "Trait_2", "Trait_3"].span(),
            trait_values: array!["Value_1", "Value_2", "Value_3"].span(),
        })
    }
    fn get_type(self: TokenData) -> ByteArray {
        ("1")
    }
    fn get_name(self: TokenData) -> ByteArray {
        (format!("512 Karat #{}", self.token_id))
    }
    fn get_description(self: TokenData) -> ByteArray {
        ("Fully on-chain Generative Art made with Dojo")
    }
}


 