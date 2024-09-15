use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use karat::{
    models::seed::{Seed, SeedTrait},
    models::class::{Class, ClassTrait},
};
use karat::utils::short_string::{ShortStringTrait};

mod CONSTANTS {
    const TOKEN_NAME: felt252 = 'KARAT';
    const TOKEN_SYMBOL: felt252 = 'KARAT';
    const BASE_URI: felt252 = 'https://karat.collect-code.com/';
    const METADATA_NAME: felt252 = 'Karat';
    const METADATA_DESCRIPTION: felt252 = 'Purest form of composable lore';
}

#[derive(Copy, Drop, Serde)]
// #[dojo::model]
pub struct TokenData {
    pub token_id: u128,
    pub seed: u128,
    pub trait_names: Span<ByteArray>,
    pub trait_values: Span<ByteArray>,
    pub class: Class,
}

#[generate_trait]
impl TokenDataTraitImpl of TokenDataTrait {
    fn new(world: IWorldDispatcher, token_id: u128) -> TokenData {
        let seed: Seed = get!(world, (token_id), Seed);
        let class: Class = seed.get_class();
        (TokenData{
            token_id,
            seed: seed.seed,
            trait_names: array![
                "Class",
                "Realm",
            ].span(),
            trait_values: array![
                class.name(),
                format!("{}", seed.get_realm_id()),
            ].span(),
            class,
        })
    }
    fn get_name(self: TokenData) -> ByteArray {
        (format!("{} #{}", CONSTANTS::METADATA_NAME.string(), self.token_id))
    }
    fn get_description(self: TokenData) -> ByteArray {
        (CONSTANTS::METADATA_DESCRIPTION.string())
    }
}
