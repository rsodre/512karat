
mod painter {
    use debug::PrintTrait;
    use zeroable::Zeroable;
    use starknet::{ContractAddress, get_contract_address, get_caller_address};
    use karat::systems::karat_token::{IKaratTokenDispatcher, IKaratTokenDispatcherTrait};
    use karat::models::{
        config::{Config, ConfigManager, ConfigManagerTrait},
    };

    fn build_uri(token_id: u256) -> ByteArray {
        return format!("_new_uri_{}", token_id);
    }
}
