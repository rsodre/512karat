#[cfg(test)]
mod tester {
    use debug::PrintTrait;
    use starknet::testing;
    use starknet::{ContractAddress};
    use starknet::class_hash::Felt252TryIntoClassHash;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::utils::test::{spawn_test_world, deploy_contract};

    // karat
    use karat::{
        systems::{minter::{minter, IMinterDispatcher, IMinterDispatcherTrait}},
        systems::{karat_token::{karat_token, IKaratTokenDispatcher, IKaratTokenDispatcherTrait}},
    };

    // token
    use origami_token::components::token::erc721::erc721_enumerable::erc721_enumerable_component::{
        ERC721EnumerableImpl, InternalImpl as ERC721EnumerableInternalImpl
    };
    use origami_token::tests::constants::{ZERO, OWNER, SPENDER, RECIPIENT, VALUE, TOKEN_ID, TOKEN_ID_2};
    use origami_token::tests::utils;

    // set_contract_address : to define the address of the calling contract,
    // set_account_contract_address : to define the address of the account used for the current transaction.
    fn impersonate(address: ContractAddress) {
        testing::set_contract_address(address);
        testing::set_account_contract_address(address);
    }

    #[derive(Drop, Copy, Serde)]
    struct Systems {
        world: IWorldDispatcher,
        karat: IKaratTokenDispatcher,
        minter: IMinterDispatcher,
        max_supply: u128,
        available_supply: u128,
    }

    fn spawn_systems() -> Systems {
        let world = spawn_test_world(["dojo", "origami_karat", "karat"].span(),  get_models_test_class_hashes!());

        let max_supply: u128 = 6;
        let available_supply: u128 = 4;
        
        let karat = IKaratTokenDispatcher {
            contract_address: world.deploy_contract('karat', karat_token::TEST_CLASS_HASH.try_into().unwrap())
        };
        world.grant_owner(dojo::utils::bytearray_hash(@"origami_karat"), karat.contract_address);
        world.init_contract(selector_from_tag!("karat-karat_token"), [].span());

        let minter_calldata: Span<felt252> = array![
            karat.contract_address.into(),
            max_supply.into(),
            available_supply.into(),
        ].span();
        let minter = IMinterDispatcher {
            contract_address:world.deploy_contract('minter', minter::TEST_CLASS_HASH.try_into().unwrap())
        };
        world.grant_owner(dojo::utils::bytearray_hash(@"origami_karat"), minter.contract_address);
        world.grant_owner(dojo::utils::bytearray_hash(@"karat"), minter.contract_address);
        world.grant_owner(selector_from_tag!("karat-karat_token"), OWNER());
        world.grant_owner(selector_from_tag!("karat-minter"), OWNER());
        world.init_contract(selector_from_tag!("karat-minter"), minter_calldata);

        impersonate(OWNER());

        utils::drop_all_events(karat.contract_address);
        utils::drop_all_events(world.contract_address);

        (Systems{
            world,
            karat,
            minter,
            max_supply,
            available_supply,
        })
    }

    // event helpers
    // examples...
    // https://docs.swmansion.com/scarb/corelib/core-starknet-testing-pop_log.html
    // https://github.com/cartridge-gg/arcade/blob/7e3a878192708563082eaf2adfd57f4eec0807fb/packages/achievement/src/tests/test_achievable.cairo#L77-L92
    pub fn pop_log<T, +Drop<T>, +starknet::Event<T>>(address: ContractAddress, event_selector: felt252) -> Option<T> {
        let (mut keys, mut data) = testing::pop_log_raw(address)?;
        let id = keys.pop_front().unwrap(); // Remove the event ID from the keys
        assert_eq!(id, @event_selector, "Wrong event!");
        let ret = starknet::Event::deserialize(ref keys, ref data);
        assert!(data.is_empty(), "Event has extra data (wrong event?)");
        assert!(keys.is_empty(), "Event has extra keys (wrong event?)");
        (ret)
    }
    pub fn assert_no_events_left(address: ContractAddress) {
        assert!(testing::pop_log_raw(address).is_none(), "Events remaining on queue");
    }
    pub fn drop_event(address: ContractAddress) {
        match testing::pop_log_raw(address) {
            core::option::Option::Some(_) => {},
            core::option::Option::None => {},
        };
    }
    pub fn drop_all_events(address: ContractAddress) {
        loop {
            match testing::pop_log_raw(address) {
                core::option::Option::Some(_) => {},
                core::option::Option::None => { break; },
            };
        }
    }


    //---------------------------------------
    // misc helpers
    //
    pub fn starts_with(input: ByteArray, prefix: ByteArray) -> bool {
        (if (input.len() < prefix.len()) {
            (false)
        } else {
            let mut result = true;
            let mut i = 0;
            while (i < prefix.len()) {
                if (input[i] != prefix[i]) {
                    result = false;
                    break;
                }
                i += 1;
            };
            (result)
        })
    }
}
