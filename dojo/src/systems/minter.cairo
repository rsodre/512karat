use starknet::{ContractAddress};
use karat::models::{
    token_data::{TokenData},
};

#[dojo::interface]
trait IMinter {
    fn mint(ref world: IWorldDispatcher, token_contract_address: ContractAddress) -> u128;
    fn mint_to(ref world: IWorldDispatcher, token_contract_address: ContractAddress, recipient: ContractAddress) -> u128;
    fn set_available(ref world: IWorldDispatcher, token_contract_address: ContractAddress, available_supply: u128);
    fn get_token_data(world: @IWorldDispatcher, token_id: u128) -> TokenData;
    // fn get_token_svg(ref world: IWorldDispatcher, token_id: u128) -> ByteArray;
}

#[dojo::interface]
trait IMinterInternal {
    fn assert_caller_is_owner(world: @IWorldDispatcher);
    fn caller_is_owner(world: @IWorldDispatcher) -> bool;
}

#[dojo::interface]
trait IRenderer {
    fn render_uri(world: @IWorldDispatcher, token_id: u128) -> ByteArray;
}

#[dojo::contract]
mod minter {
    use debug::PrintTrait;
    use super::{IMinter};
    use zeroable::Zeroable;
    use starknet::{ContractAddress, get_contract_address, get_caller_address};
    use karat::systems::karat_token::{IKaratTokenDispatcher, IKaratTokenDispatcherTrait};
    use karat::utils::renderer::{renderer};
    use karat::utils::misc::{WORLD};
    use karat::models::{
        config::{Config, ConfigTrait},
        token_data::{TokenData, TokenDataTrait},
        seed::{Seed, SeedTrait},
    };

    mod Errors {
        const INVALID_TOKEN_ADDRESS: felt252 = 'KARAT: invalid token address';
        const INVALID_SUPPLY: felt252 = 'KARAT: invalid supply';
        const MINTED_OUT: felt252 = 'KARAT: minted out';
        const UNAVAILABLE: felt252 = 'KARAT: unavailable';
        const COOLING_DOWN: felt252 = 'KARAT: cool down!';
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
        available_supply: u128,
    ) {
        // 'dojo_init()...'.print();

        assert(token_address.is_non_zero(), Errors::INVALID_TOKEN_ADDRESS);
        assert(max_supply > 0, Errors::INVALID_SUPPLY);

        //
        // Config
        set!(world, (Config{
            token_address,
            minter_address: get_contract_address(),
            renderer_address: get_contract_address(),
            max_supply,
            available_supply,
            cool_down: true,
        }));
    }

    //---------------------------------------
    // IMinter
    //
    #[abi(embed_v0)]
    impl MinterImpl of IMinter<ContractState> {
        fn mint(ref world: IWorldDispatcher, token_contract_address: ContractAddress) -> u128 {
            WORLD(world);
            (self.mint_to(token_contract_address, get_caller_address()))
        }
        fn mint_to(ref world: IWorldDispatcher, token_contract_address: ContractAddress, recipient: ContractAddress) -> u128 {
            let karat = (IKaratTokenDispatcher{contract_address:token_contract_address});
            let total_supply: u256 = karat.total_supply();

            // check availability
            let is_owner: bool = self.caller_is_owner();
            let config: Config = get!(world, (token_contract_address), Config);
            assert(total_supply.low < config.max_supply, Errors::MINTED_OUT);
            assert(total_supply.low < config.available_supply || is_owner, Errors::UNAVAILABLE);
            
            // get next token_id
            let token_id: u256 = (total_supply + 1);

            // very simple cool down rule
            // avoid wallets to make consecutive mints
            if (config.cool_down && token_id > 1 && !is_owner) {
                let last_owner: ContractAddress = karat.owner_of(token_id - 1);
                assert(last_owner != recipient, Errors::COOLING_DOWN);
                assert(last_owner != get_caller_address(), Errors::COOLING_DOWN);
            }

            // mint!
            karat.mint(recipient, token_id);

            // generate seed
            let seed = SeedTrait::new(token_id.low);
            set!(world, (seed));

            // return minted token id
            (token_id.low)
        }

        fn set_available(ref world: IWorldDispatcher, token_contract_address: ContractAddress, available_supply: u128) {
            self.assert_caller_is_owner();
            let mut config: Config = get!(world, (token_contract_address), Config);
            config.available_supply = available_supply;
            set!(world, (config));
        }

        fn get_token_data(world: @IWorldDispatcher, token_id: u128) -> TokenData {
            (TokenDataTrait::new(world, token_id))
        }
    }

    impl InternalImpl of super::IMinterInternal<ContractState> {
        #[inline(always)]
        fn assert_caller_is_owner(world: @IWorldDispatcher) {
            WORLD(world);
            assert(self.caller_is_owner(), Errors::NOT_OWNER);
        }
        #[inline(always)]
        fn caller_is_owner(world: @IWorldDispatcher) -> bool {
            (world.is_owner(self.selector().into(), get_caller_address()))
        }
    }

    //---------------------------------------
    // IRenderer
    //
    #[abi(embed_v0)]
    impl RendererImpl of super::IRenderer<ContractState> {
        fn render_uri(world: @IWorldDispatcher, token_id: u128) -> ByteArray {
            WORLD(world);
            let token_data = self.get_token_data(token_id);
            return renderer::build_uri(token_data);
        }
    }
}
