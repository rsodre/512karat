use integer::BoundedInt;
use starknet::{ContractAddress, get_contract_address, get_caller_address};
use starknet::storage::{StorageMemberAccessTrait};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use dojo::test_utils::spawn_test_world;
use token::tests::constants::{ZERO, OWNER, SPENDER, RECIPIENT, TOKEN_ID, TOKEN_ID_2, TOKEN_ID_3};

use token::tests::utils;

use token::components::introspection::src5::src5_component::{SRC5Impl};
use token::components::token::erc721::interface::{
    IERC721_ID, IERC721_METADATA_ID, IERC721_ENUMERABLE_ID,
};

use token::components::token::erc721::erc721_approval::{
    erc_721_token_approval_model, ERC721TokenApprovalModel, erc_721_operator_approval_model,
    ERC721OperatorApprovalModel
};
use token::components::token::erc721::erc721_approval::erc721_approval_component;
use token::components::token::erc721::erc721_approval::erc721_approval_component::{
    Approval, ApprovalForAll, ERC721ApprovalImpl, InternalImpl as ERC721ApprovalInternalImpl
};


use token::components::token::erc721::erc721_metadata::{erc_721_meta_model, ERC721MetaModel,};
use token::components::token::erc721::erc721_metadata::erc721_metadata_component::{
    ERC721MetadataImpl, ERC721MetadataCamelImpl, InternalImpl as ERC721MetadataInternalImpl
};

use token::components::token::erc721::erc721_balance::{erc_721_balance_model, ERC721BalanceModel,};
use token::components::token::erc721::erc721_balance::erc721_balance_component::{
    Transfer, ERC721BalanceImpl, InternalImpl as ERC721BalanceInternalImpl
};

use token::components::token::erc721::erc721_mintable::erc721_mintable_component::InternalImpl as ERC721MintableInternalImpl;
use token::components::token::erc721::erc721_burnable::erc721_burnable_component::InternalImpl as ERC721BurnableInternalImpl;

use karat::systems::karat_token::{
    karat_token, IKaratTokenDispatcher, IKaratTokenDispatcherTrait,
};
use karat::models::{
    config::{Config, ConfigTrait, ConfigManager, ConfigManagerTrait},
    seed::{Seed, SeedTrait},
};

//
// events helpers
//

fn assert_event_transfer(
    emitter: ContractAddress, from: ContractAddress, to: ContractAddress, token_id: u256
) {
    let event = utils::pop_log::<Transfer>(emitter).unwrap();
    assert(event.from == from, 'Invalid `from`');
    assert(event.to == to, 'Invalid `to`');
    assert(event.token_id == token_id, 'Invalid `token_id`');
}

fn assert_only_event_transfer(
    emitter: ContractAddress, from: ContractAddress, to: ContractAddress, token_id: u256
) {
    assert_event_transfer(emitter, from, to, token_id);
    utils::assert_no_events_left(emitter);
}

fn assert_event_approval(
    emitter: ContractAddress, owner: ContractAddress, spender: ContractAddress, token_id: u256
) {
    let event = utils::pop_log::<Approval>(emitter).unwrap();
    assert(event.owner == owner, 'Invalid `owner`');
    assert(event.spender == spender, 'Invalid `spender`');
    assert(event.token_id == token_id, 'Invalid `token_id`');
}

fn assert_only_event_approval(
    emitter: ContractAddress, owner: ContractAddress, spender: ContractAddress, token_id: u256
) {
    assert_event_approval(emitter, owner, spender, token_id);
    utils::assert_no_events_left(emitter);
}


//
// Setup
//

fn setup_uninitialized() -> (IWorldDispatcher, IKaratTokenDispatcher) {
    let world = spawn_test_world(
        array![
            erc_721_token_approval_model::TEST_CLASS_HASH,
            erc_721_balance_model::TEST_CLASS_HASH,
            erc_721_meta_model::TEST_CLASS_HASH,
        ]
    );

    // deploy contract
    let mut token_dispatcher = IKaratTokenDispatcher {
        contract_address: world.deploy_contract('salt', karat_token::TEST_CLASS_HASH.try_into().unwrap(), array![].span())
    };

    // setup auth
    world.grant_writer(selector!("SRC5Model"), token_dispatcher.contract_address);
    world.grant_writer(selector!("InitializableModel"), token_dispatcher.contract_address);
    world.grant_writer(selector!("ERC721MetaModel"), token_dispatcher.contract_address);
    world.grant_writer(selector!("ERC721TokenApprovalModel"), token_dispatcher.contract_address);
    world.grant_writer(selector!("ERC721BalanceModel"), token_dispatcher.contract_address);
    world.grant_writer(selector!("ERC721EnumerableIndexModel"),token_dispatcher.contract_address);
    world.grant_writer(selector!("ERC721EnumerableOwnerIndexModel"),token_dispatcher.contract_address);
    world.grant_writer(selector!("ERC721EnumerableTokenModel"),token_dispatcher.contract_address);
    world.grant_writer(selector!("ERC721EnumerableOwnerTokenModel"),token_dispatcher.contract_address);
    world.grant_writer(selector!("ERC721EnumerableTotalModel"),token_dispatcher.contract_address);
    world.grant_writer(selector!("ERC721MetadataModel"), token_dispatcher.contract_address);
    world.grant_writer(selector!("ERC721OwnerModel"), token_dispatcher.contract_address);
    world.grant_writer(selector!("Config"), token_dispatcher.contract_address);
    world.grant_writer(selector!("TokenData"), token_dispatcher.contract_address);
    
    world.grant_writer(selector!("SRC5Model"), OWNER());
    world.grant_writer(selector!("InitializableModel"), OWNER());
    world.grant_writer(selector!("ERC721MetaModel"), OWNER());
    world.grant_writer(selector!("ERC721TokenApprovalModel"),  OWNER());
    world.grant_writer(selector!("ERC721BalanceModel"),  OWNER());
    world.grant_writer(selector!("ERC721EnumerableIndexModel"), OWNER());
    world.grant_writer(selector!("ERC721EnumerableOwnerIndexModel"), OWNER());
    world.grant_writer(selector!("ERC721EnumerableTokenModel"), OWNER());
    world.grant_writer(selector!("ERC721EnumerableOwnerTokenModel"), OWNER());
    world.grant_writer(selector!("ERC721EnumerableTotalModel"), OWNER());
    world.grant_writer(selector!("ERC721MetadataModel"),  OWNER());
    world.grant_writer(selector!("ERC721OwnerModel"),  OWNER());
    world.grant_writer(selector!("Config"), OWNER());
    world.grant_writer(selector!("TokenData"), OWNER());

    utils::impersonate(OWNER());
    let manager = ConfigManagerTrait::new(world);
    manager.set(Config{
        token_address: token_dispatcher.contract_address,
        minter_address: OWNER(),
        painter_address: token_dispatcher.contract_address,
        max_supply: 512,
        cool_down: false,
        is_open: true,
    });

    (world, token_dispatcher)
}

fn setup() -> (IWorldDispatcher, IKaratTokenDispatcher) {
    let (world, mut token_dispatcher) = setup_uninitialized();

    // initialize contracts
    token_dispatcher.initialize("NAME", "SYMBOL", "URI");
    token_dispatcher.mint(OWNER(), TOKEN_ID);
    token_dispatcher.mint(OWNER(), TOKEN_ID_2);

    // drop all events
    utils::drop_all_events(token_dispatcher.contract_address);
    utils::drop_all_events(world.contract_address);

    (world, token_dispatcher)
}

//
// initialize
//

#[test]
fn test_initializer() {
    let (_world, mut token_dispatcher) = setup();

    assert(token_dispatcher.balance_of(OWNER()) == 2, 'Should eq 2');
    assert(token_dispatcher.name() == "NAME", 'Name should be NAME');
    assert(token_dispatcher.symbol() == "SYMBOL", 'Symbol should be SYMBOL');
    // no painter here to build uri
    // assert(token_dispatcher.token_uri(TOKEN_ID) == "URI21", 'Uri should be URI21');
    // assert(token_dispatcher.tokenURI(TOKEN_ID) == "URI21", 'Uri should be URI21 Camel');
    
    assert(token_dispatcher.supports_interface(IERC721_ID) == true, 'should support IERC721_ID');
    assert(token_dispatcher.supports_interface(IERC721_METADATA_ID) == true, 'should support METADATA');
    assert(token_dispatcher.supports_interface(IERC721_ENUMERABLE_ID) == true, 'should support ENUMERABLE');
    assert(token_dispatcher.supportsInterface(IERC721_ID) == true, 'should support IERC721_ID Camel');
}

// #[test]
// #[should_panic(expected: ('ERC721: caller is not owner', 'ENTRYPOINT_FAILED'))]
// fn test_initialize_not_world_owner() {
//     let (_world, mut token_dispatcher) = setup_uninitialized();

//     utils::impersonate(OWNER());

//     // initialize contracts
//     token_dispatcher.initialize("NAME", "SYMBOL", "URI");
// }

#[test]
#[should_panic(expected: ('Initializable: is initialized', 'ENTRYPOINT_FAILED'))]
fn test_initialize_multiple() {
    let (_world, mut token_dispatcher) = setup();

    token_dispatcher.initialize("NAME", "SYMBOL", "URI");
}

//
// approve
//

#[test]
fn test_approve() {
    let (world, mut token_dispatcher) = setup();

    utils::impersonate(OWNER());

    token_dispatcher.approve(SPENDER(), TOKEN_ID);
    assert(token_dispatcher.get_approved(TOKEN_ID) == SPENDER(), 'Spender not approved correctly');

    // drop StoreSetRecord ERC721TokenApprovalModel
    utils::drop_event(world.contract_address);

    assert_only_event_approval(token_dispatcher.contract_address, OWNER(), SPENDER(), TOKEN_ID);
    assert_only_event_approval(world.contract_address, OWNER(), SPENDER(), TOKEN_ID);
}

//
// transfer_from
//

#[test]
fn test_transfer_from() {
    let (world, mut token_dispatcher) = setup();

    utils::impersonate(OWNER());
    token_dispatcher.approve(SPENDER(), TOKEN_ID);

    utils::drop_all_events(token_dispatcher.contract_address);
    utils::drop_all_events(world.contract_address);
    utils::assert_no_events_left(token_dispatcher.contract_address);

    utils::impersonate(SPENDER());
    token_dispatcher.transfer_from(OWNER(), RECIPIENT(), TOKEN_ID);

    assert_only_event_transfer(token_dispatcher.contract_address, OWNER(), RECIPIENT(), TOKEN_ID);

    assert(token_dispatcher.balance_of(RECIPIENT()) == 1, 'Should eq 1');
    assert(token_dispatcher.balance_of(OWNER()) == 1, 'Should eq 1');
    assert(token_dispatcher.get_approved(TOKEN_ID) == ZERO(), 'Should eq 0');
    assert(token_dispatcher.total_supply() == 2, 'Should eq 2');
    assert(token_dispatcher.token_by_index(0) == TOKEN_ID, 'Should eq TOKEN_ID');
    assert(
        token_dispatcher.token_of_owner_by_index(RECIPIENT(), 0) == TOKEN_ID, 'Should eq TOKEN_ID'
    );
}

//
// mint
//

#[test]
fn test_mint() {
    let (_world, mut token_dispatcher) = setup();

    token_dispatcher.mint(RECIPIENT(), 3);
    assert(token_dispatcher.balance_of(RECIPIENT()) == 1, 'invalid balance_of');
    assert(token_dispatcher.total_supply() == 3, 'invalid total_supply');
    assert(token_dispatcher.token_by_index(2) == 3, 'invalid token_by_index');
    assert(
        token_dispatcher.token_of_owner_by_index(RECIPIENT(), 0) == 3,
        'invalid token_of_owner_by_index'
    );
}

//
// burn
//

#[test]
fn test_burn() {
    let (_world, mut token_dispatcher) = setup();

    token_dispatcher.burn(TOKEN_ID_2);
    assert(token_dispatcher.balance_of(OWNER()) == 1, 'invalid balance_of');
    assert(token_dispatcher.total_supply() == 1, 'invalid total_supply');
    assert(token_dispatcher.token_by_index(0) == TOKEN_ID, 'invalid token_by_index');
    assert(
        token_dispatcher.token_of_owner_by_index(OWNER(), 0) == TOKEN_ID,
        'invalid token_of_owner_by_index'
    );
}

