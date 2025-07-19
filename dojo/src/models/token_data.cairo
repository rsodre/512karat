use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use karat::models::{
    seed::{Seed, SeedTrait},
    class::{Class, ClassTrait},
    constants::{CONST},
};

#[derive(Copy, Drop, Serde)]
// #[dojo::model]
pub struct TokenData {
    pub token_id: u128,
    pub seed: u128,
    pub trait_names: Span<ByteArray>,
    pub trait_values: Span<ByteArray>,
    pub class: Class,
}

#[derive(Drop, Serde)]
// #[dojo::model]
pub struct ContractData {
    pub name: ByteArray,
    pub symbol: ByteArray,
    pub description: ByteArray,
    // optionals
    pub image: ByteArray,
    // pub banner_image: Option<ByteArray>,
    // pub featured_image: Option<ByteArray>,
    pub external_link: ByteArray,
    // pub collaborators: Option<Span<ContractAddress>>,
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
                "Matrix",
                "Realm",
            ].span(),
            trait_values: array![
                class.name(),
                seed.get_matrix(),
                format!("{}", seed.get_realm_id()),
            ].span(),
            class,
        })
    }
    fn get_name(self: TokenData) -> @ByteArray {
        @(format!("{} #{}", CONST::const_string(CONST::TOKEN_NAME), self.token_id))
    }
    fn get_description(self: TokenData) -> @ByteArray {
        @(CONST::const_string(CONST::METADATA_DESCRIPTION))
    }
}
