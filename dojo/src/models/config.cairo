use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
pub struct Config {
    #[key]
    pub token_address: ContractAddress,
    //------
    pub minter_address: ContractAddress,
    pub renderer_address: ContractAddress,
    pub max_supply: u128,
    pub available_supply: u128,
    pub cool_down: bool,
    // karat_v1.1
    pub royalty_receiver: ContractAddress,
    pub royalty_fraction: u128,
    pub purchase_coin_address: ContractAddress,
    pub purchase_price_eth: u8,
}

#[generate_trait]
impl ConfigTraitImpl of ConfigTrait {
    fn is_minter(self: Config, address: ContractAddress) -> bool { (self.minter_address == address) }
}
