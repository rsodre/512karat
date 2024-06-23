use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use karat::{
    models::seed::{Seed, SeedTrait},
    models::class::{Class, ClassTrait},
};

#[derive(Copy, Drop, Serde)]
// #[dojo::model]
struct TokenData {
    token_id: u128,
    seed: u128,
    trait_names: Span<ByteArray>,
    trait_values: Span<ByteArray>,
    class: Class,
}

#[generate_trait]
impl TokenDataTraitImpl of TokenDataTrait {
    fn new(world: IWorldDispatcher, token_id: u128) -> TokenData {
        let seed: Seed = get!(world, (token_id), Seed);
        let class: Class = seed.to_class();
        (TokenData{
            token_id,
            seed: seed.seed,
            trait_names: array![
                "Class",
                "Realm",
            ].span(),
            trait_values: array![
                class.name(),
                format!("{}", seed.realm_id()),
            ].span(),
            class,
        })
    }
    fn get_name(self: TokenData) -> ByteArray {
        (format!("512 Karat #{}", self.token_id))
    }
    fn get_description(self: TokenData) -> ByteArray {
        ("Fully on-chain Generative Art made with Dojo")
    }
}


 