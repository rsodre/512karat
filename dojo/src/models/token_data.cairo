use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use karat::{
    models::seed::{Seed, SeedTrait},
};

#[derive(Copy, Drop, Serde)]
// #[dojo::model]
struct TokenData {
    token_id: u128,
    seed: u128,
    trait_names: Span<felt252>,
    trait_values: Span<felt252>,
}

#[generate_trait]
impl TokenDataTraitImpl of TokenDataTrait {
    fn new(world: IWorldDispatcher, token_id: u128) -> TokenData {
        let seed: Seed = get!(world, (token_id), Seed);
        (TokenData{
            token_id,
            seed: seed.seed,
            trait_names: array!['Trait_1', 'Trait_2', 'Trait_3'].span(),
            trait_values: array!['Value_1', 'Value_2', 'Value_3'].span(),
        })
    }
}


 