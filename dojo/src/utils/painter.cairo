mod painter {
    use debug::PrintTrait;
    use zeroable::Zeroable;
    use starknet::{ContractAddress, get_contract_address, get_caller_address};
    use karat::systems::karat_token::{IKaratTokenDispatcher, IKaratTokenDispatcherTrait};
    use karat::models::{
        config::{Config, ConfigManager, ConfigManagerTrait},
        token_data::{TokenData, TokenDataTrait},
    };

    fn build_uri(token_data: TokenData) -> ByteArray {
        return format!("/{}/{}", token_data.seed, token_data.token_id);
    }
}
