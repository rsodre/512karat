use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[inline(always)]
fn WORLD(_world: IWorldDispatcher) {}

#[inline(always)]
fn ZERO() -> starknet::ContractAddress {
    starknet::contract_address_const::<0>()
}

pub const ETH_TO_WEI: u256 = 1_000_000_000_000_000_000;
pub fn WEI(eth: u256) -> u256 { eth * ETH_TO_WEI }
pub fn ETH(wei: u256) -> u256 { wei / ETH_TO_WEI }
