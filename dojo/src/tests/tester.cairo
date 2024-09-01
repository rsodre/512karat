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
    }

    fn spawn_systems() -> Systems {
        let world = spawn_test_world(["dojo", "origami_token", "karat"].span(),  get_models_test_class_hashes!());

        let max_supply: u128 = 4;
        
        let karat = IKaratTokenDispatcher {
            contract_address: world.deploy_contract('karat', karat_token::TEST_CLASS_HASH.try_into().unwrap())
        };
        world.grant_owner(dojo::utils::bytearray_hash(@"origami_token"), karat.contract_address);

        let minter_calldata: Span<felt252> = array![
            karat.contract_address.into(),
            max_supply.into(),
            1,
        ].span();
        let minter = IMinterDispatcher {
            contract_address:world.deploy_contract('minter', minter::TEST_CLASS_HASH.try_into().unwrap())
        };
        world.grant_owner(dojo::utils::bytearray_hash(@"origami_token"), minter.contract_address);
        world.grant_owner(dojo::utils::bytearray_hash(@"karat"), minter.contract_address);
        world.grant_owner(selector_from_tag!("karat-minter"), OWNER());
        world.init_contract(selector_from_tag!("karat-minter"), minter_calldata);

        impersonate(OWNER());

        (Systems{
            world,
            karat,
            minter,
            max_supply,
        })
    }
}
