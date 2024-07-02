use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct Config {
    #[key]
    token_address: ContractAddress,
    //------
    minter_address: ContractAddress,
    painter_address: ContractAddress,
    max_supply: u128,
    cool_down: bool,
    is_open: bool,
}

#[generate_trait]
impl ConfigTraitImpl of ConfigTrait {
    fn is_minter(self: Config, address: ContractAddress) -> bool { (self.minter_address == address) }
}
