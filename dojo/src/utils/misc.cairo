use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[inline(always)]
fn WORLD(_world: IWorldDispatcher) {}

#[inline(always)]
fn ZERO() -> starknet::ContractAddress {
    starknet::contract_address_const::<0>()
}
