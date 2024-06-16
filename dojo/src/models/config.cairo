use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Config {
    #[key]
    token_address: ContractAddress,
    //------
    minter_address: ContractAddress,
    painter_address: ContractAddress,
    max_supply: u128,
    is_open: bool,
}

#[generate_trait]
impl ConfigTraitImpl of ConfigTrait {
    fn is_minter(self: Config, address: ContractAddress) -> bool { (self.minter_address == address) }
}

#[derive(Copy, Drop)]
struct ConfigManager {
    world: IWorldDispatcher
}

#[generate_trait]
impl ConfigManagerTraitImpl of ConfigManagerTrait {
    fn new(world: IWorldDispatcher) -> ConfigManager {
        ConfigManager { world }
    }
    fn get(self: ConfigManager, token_address: ContractAddress) -> Config {
        get!(self.world, (token_address), Config)
    }
    fn set(self: ConfigManager, config: Config) {
        set!(self.world, (config));
    }
}
