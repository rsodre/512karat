use starknet::{ContractAddress};
use karat::models::{
    token_data::{TokenData},
};

#[dojo::interface]
trait IMinter {
    fn mint(ref world: IWorldDispatcher, token_contract_address: ContractAddress) -> u128;
    fn set_open(ref world: IWorldDispatcher, token_contract_address: ContractAddress, is_open: bool);
    fn get_token_data(world: @IWorldDispatcher, token_id: u128) -> TokenData;
    // fn get_token_svg(ref world: IWorldDispatcher, token_id: u128) -> ByteArray;
}

#[dojo::interface]
trait IMinterInternal {
    fn assert_caller_is_owner(world: @IWorldDispatcher);
}

#[dojo::interface]
trait IPainter {
    fn paint(world: @IWorldDispatcher, token_id: u128) -> ByteArray;
}

#[dojo::contract]
mod minter {
    use debug::PrintTrait;
    use super::{IMinter};
    use zeroable::Zeroable;
    use starknet::{ContractAddress, get_contract_address, get_caller_address};
    use karat::systems::karat_token::{IKaratTokenDispatcher, IKaratTokenDispatcherTrait};
    use karat::utils::painter::{painter};
    use karat::models::{
        config::{Config, ConfigTrait},
        token_data::{TokenData, TokenDataTrait},
        seed::{Seed, SeedTrait},
    };

    mod Errors {
        const INVALID_TOKEN_ADDRESS: felt252 = 'KARAT: invalid token address';
        const INVALID_SUPPLY: felt252 = 'KARAT: invalid supply';
        const MINT_CLOSED: felt252 = 'KARAT: minting is closed';
        const MINTED_OUT: felt252 = 'KARAT: minted out';
        const NOT_AGAIN: felt252 = 'KARAT: dont be greedy!';
        const NOT_OWNER: felt252 = 'KARAT: not owner';
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
        // 'dojo_init()...'.print();
        
        //*******************************
        let TOKEN_NAME = "512 KARAT";
        let TOKEN_SYMBOL = "512KARAT";
        let BASE_URI = "/";
        //*******************************

        assert(token_address.is_non_zero(), Errors::INVALID_TOKEN_ADDRESS);
        assert(max_supply > 0, Errors::INVALID_SUPPLY);

        //
        // Config
        set!(world, (Config{
            token_address,
            minter_address: get_contract_address(),
            painter_address: get_contract_address(),
            max_supply,
            cool_down: true,
            is_open: (is_open != 0),
        }));

        //
        // initialize token
        let karat = (IKaratTokenDispatcher{ contract_address: token_address });
        karat.initialize(TOKEN_NAME, TOKEN_SYMBOL, BASE_URI);
    }

    //---------------------------------------
    // IMinter
    //
    #[abi(embed_v0)]
    impl MinterImpl of IMinter<ContractState> {
        fn mint(ref world: IWorldDispatcher, token_contract_address: ContractAddress) -> u128 {
            let karat = (IKaratTokenDispatcher{contract_address:token_contract_address});
            let total_supply: u256 = karat.total_supply();

            // check availability
            let config: Config = get!(world, (token_contract_address), Config);
            assert(total_supply.low < config.max_supply, Errors::MINTED_OUT);
            assert(config.is_open, Errors::MINT_CLOSED);
            
            // get next token_id
            let token_id: u256 = (total_supply + 1);

            // very simple cool down rule
            // avoid wallets to make consecutive mints
            if (config.cool_down && token_id > 1) {
                let owner: ContractAddress = karat.owner_of(token_id - 1);
                assert(
                    owner != get_caller_address(),
                    Errors::NOT_AGAIN,
                )
            }

            // mint!
            karat.mint(get_caller_address(), token_id);

            // generate seed
            let seed = SeedTrait::new(token_id.low);
            set!(world, (seed));

            // return minted token id
            (token_id.low)
        }

        fn set_open(ref world: IWorldDispatcher, token_contract_address: ContractAddress, is_open: bool) {
            self.assert_caller_is_owner();
            let mut config: Config = get!(world, (token_contract_address), Config);
            config.is_open = is_open;
            set!(world, (config));
        }

        fn get_token_data(world: @IWorldDispatcher, token_id: u128) -> TokenData {
            (TokenDataTrait::new(world, token_id))
        }
    }

    impl InternalImpl of super::IMinterInternal<ContractState> {
        #[inline(always)]
        fn assert_caller_is_owner(world: @IWorldDispatcher) {
            assert(world.is_owner(get_caller_address(), get_contract_address().into()), Errors::NOT_OWNER);
        }
    }

    //---------------------------------------
    // IPainter
    //
    #[abi(embed_v0)]
    impl PainterImpl of super::IPainter<ContractState> {
        fn paint(world: @IWorldDispatcher, token_id: u128) -> ByteArray {
            let token_data = self.get_token_data(token_id);
            return painter::build_uri(token_data);
        }
    }
}
