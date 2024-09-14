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
    pub cool_down: bool,
    pub is_open: bool,
}

#[generate_trait]
impl ConfigTraitImpl of ConfigTrait {
    fn is_minter(self: Config, address: ContractAddress) -> bool { (self.minter_address == address) }
}
