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
        models::{position::{Position, Vec2, position}, moves::{Moves, Direction, moves}}
    };

    // token
    use token::tests::constants::{ZERO, OWNER, SPENDER, RECIPIENT, VALUE, TOKEN_ID, TOKEN_ID_2};
    use token::tests::utils;
    use token::components::token::erc721::erc721_enumerable::{
        erc_721_enumerable_index_model, ERC721EnumerableIndexModel,
        erc_721_enumerable_owner_index_model, ERC721EnumerableOwnerIndexModel,
        erc_721_enumerable_total_model, ERC721EnumerableTotalModel
    };
    use token::components::token::erc721::erc721_enumerable::erc721_enumerable_component::{
        ERC721EnumerableImpl, InternalImpl as ERC721EnumerableInternalImpl
    };
    // use token::components::tests::mocks::erc721::erc721_enumerable_mock::{
    //     erc721_enumerable_mock, IERC721EnumerableMockDispatcher, IERC721EnumerableMockDispatcherTrait
    // };

    #[derive(Drop, Copy, Serde)]
    struct Systems {
        world: IWorldDispatcher,
        karat: IKaratTokenDispatcher,
        minter: IMinterDispatcher,
        // state: erc721_enumerable_mock::ContractState,
    }

    fn spawn_systems(initialize: bool) -> Systems {
        // let caller = starknet::contract_address_const::<0x0>();
        let mut models = array![
            erc_721_enumerable_index_model::TEST_CLASS_HASH,
            erc_721_enumerable_owner_index_model::TEST_CLASS_HASH,
            erc_721_enumerable_total_model::TEST_CLASS_HASH,
            position::TEST_CLASS_HASH,
            moves::TEST_CLASS_HASH,
        ];
        let world = spawn_test_world(models);

        let karat_address = world.deploy_contract('karat', karat_token::TEST_CLASS_HASH.try_into().unwrap(), array![].span());
        let karat = IKaratTokenDispatcher { contract_address: karat_address };

        let init_calldata: Span<felt252> = array![karat_address.into(), 1].span();
        let minter_address = world.deploy_contract('salt', minter::TEST_CLASS_HASH.try_into().unwrap(), init_calldata);
        let minter = IMinterDispatcher { contract_address: minter_address };

        // let mut state = erc721_enumerable_mock::contract_state_for_testing();
        // state.world_dispatcher.write(world);

        utils::drop_event(ZERO());
        testing::set_caller_address(OWNER());

        let systems = Systems{
            world,
            karat,
            minter,
            // state,
        };

        if(initialize) {
            systems.karat.initializer("KARAT", "512KARAT", "_uri_");
        }

        (systems)
    }

}
