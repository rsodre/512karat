#[cfg(test)]
mod tester {
    use debug::PrintTrait;
    use starknet::testing;
    use starknet::class_hash::Felt252TryIntoClassHash;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use dojo::test_utils::{spawn_test_world, deploy_contract};

    // karat
    use karat::{
        systems::{minter::{minter, IMinterDispatcher, IMinterDispatcherTrait}},
        systems::{karat_token::{karat_token, IKaratTokenDispatcher, IKaratTokenDispatcherTrait}},
    };

    // token
    use origami_token::tests::constants::{ZERO, OWNER, SPENDER, RECIPIENT, VALUE, TOKEN_ID, TOKEN_ID_2};
    use origami_token::tests::utils;
    use origami_token::components::token::erc721::erc721_enumerable::{
        erc_721_enumerable_index_model, ERC721EnumerableIndexModel,
        erc_721_enumerable_owner_index_model, ERC721EnumerableOwnerIndexModel,
        erc_721_enumerable_total_model, ERC721EnumerableTotalModel
    };
    use origami_token::components::token::erc721::erc721_enumerable::erc721_enumerable_component::{
        ERC721EnumerableImpl, InternalImpl as ERC721EnumerableInternalImpl
    };

    #[derive(Drop, Copy, Serde)]
    struct Systems {
        world: IWorldDispatcher,
        karat: IKaratTokenDispatcher,
        minter: IMinterDispatcher,
        max_supply: u128,
    }

    fn spawn_systems() -> Systems {
        let mut models = array![
            erc_721_enumerable_index_model::TEST_CLASS_HASH,
            erc_721_enumerable_owner_index_model::TEST_CLASS_HASH,
            erc_721_enumerable_total_model::TEST_CLASS_HASH,
        ];
        let world = spawn_test_world(models);

        let max_supply: u128 = 4;
        
        let karat_address = world.deploy_contract('karat', karat_token::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let karat = IKaratTokenDispatcher { contract_address: karat_address };

        let init_calldata: Span<felt252> = array![
            karat_address.into(),
            max_supply.into(),
            1,
        ].span();
        let minter_address = world.deploy_contract('salt', minter::TEST_CLASS_HASH.try_into().unwrap(), init_calldata);
        let minter = IMinterDispatcher { contract_address: minter_address };

        // testing::set_caller_address(OWNER()); // not it!
        testing::set_contract_address(OWNER()); // it!

        let systems = Systems{
            world,
            karat,
            minter,
            max_supply,
        };

        (systems)
    }

}
