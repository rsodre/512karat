use starknet::{ContractAddress};

// define the interface
#[dojo::interface]
trait IMinter {
    fn mint(ref world: IWorldDispatcher, contract_address: ContractAddress);
}

// dojo decorator
#[dojo::contract]
mod minter {
    use debug::PrintTrait;
    use super::{IMinter};
    use zeroable::Zeroable;
    use starknet::{ContractAddress, get_contract_address, get_caller_address};
    use karat::systems::karat_token::{IKaratTokenDispatcher, IKaratTokenDispatcherTrait};
    use karat::models::{
        config::{Config, ConfigManager, ConfigManagerTrait},
    };

    mod Errors {
        const INVALID_TOKEN_ADDRESS: felt252 = 'KARAT: invalid token address';
        const MINTED_OUT: felt252 = 'KARAT: minted out';
    }

    //---------------------------------------
    // params passed from overlays files
    // https://github.com/dojoengine/dojo/blob/328004d65bbbf7692c26f030b75fa95b7947841d/examples/spawn-and-move/manifests/dev/overlays/contracts/dojo_examples_others_others.toml
    // https://github.com/dojoengine/dojo/blob/328004d65bbbf7692c26f030b75fa95b7947841d/examples/spawn-and-move/src/others.cairo#L18
    // overlays generated with: sozo migrate --generate-overlays
    //
    fn dojo_init(
        world: @IWorldDispatcher,
        token_address: ContractAddress,
        max_supply: u128,
        is_open: u8,
    ) {
        'dojo_init()...'.print();
        
        //*******************************
        let TOKEN_NAME = "KARAT";
        let TOKEN_SYMBOL = "512 KARAT";
        let BASE_URI = "/";
        //*******************************

        //
        // Config minter
        assert(token_address.is_non_zero(), Errors::INVALID_TOKEN_ADDRESS);
        let manager = ConfigManagerTrait::new(world);
        manager.set(Config{
            token_address,
            minter_address: get_contract_address(),
            max_supply,
            is_open: (is_open != 0),
        });
        
        //
        // initialize token
        let karat = (IKaratTokenDispatcher{ contract_address: token_address });
        karat.initialize(TOKEN_NAME, TOKEN_SYMBOL, BASE_URI);
    }

    //---------------------------------------
    // Impl
    //
    #[abi(embed_v0)]
    impl MinterImpl of IMinter<ContractState> {
        fn mint(ref world: IWorldDispatcher, contract_address: ContractAddress) {
            let karat = (IKaratTokenDispatcher{contract_address});
            let total_supply: u256 = karat.total_supply();

            let config: Config = ConfigManagerTrait::new(world).get(contract_address);
            assert(total_supply.low < config.max_supply, Errors::MINTED_OUT);
            
            karat.mint(get_caller_address(), total_supply + 1);
        }
    }
}
