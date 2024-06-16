use traits::Into;

// https://github.com/starkware-libs/cairo/blob/main/corelib/src/integer.cairo
// https://github.com/smartcontractkit/chainlink-starknet/blob/develop/contracts/src/utils.cairo
use integer::{u128s_from_felt252, U128sFromFelt252Result};

// https://github.com/starkware-libs/cairo/blob/main/corelib/src/pedersen.cairo
// externals usage:
// https://github.com/shramee/starklings-cairo1/blob/main/corelib/src/hash.cairo
extern fn pedersen(a: felt252, b: felt252) -> felt252 implicits(Pedersen) nopanic;

// https://github.com/starkware-libs/cairo/blob/main/corelib/src/starknet/info.cairo
use starknet::{ContractAddress, get_block_info};

//
// initially hash based on: 
// https://github.com/shramee/cairo-random/blob/main/src/hash.cairo

fn hash_felt(seed: felt252, offset: felt252) -> felt252 {
    pedersen(seed, offset)
}

fn hash_u128(seed: u128, offset: u128) -> u128 {
    let hash = hash_felt(seed.into(), offset.into());
    felt_to_u128(hash)
}

fn felt_to_u128(value: felt252) -> u128 {
    match u128s_from_felt252(value) {
        U128sFromFelt252Result::Narrow(x) => x,
        U128sFromFelt252Result::Wide((_, x)) => x,
    }
}

fn make_seed(token_id: u128) -> u128 {
    hash_u128(token_id, _make_block_hash())
}

fn _make_block_hash() -> u128 {
    // let block_number = get_block_number();
    // let block_timestamp = get_block_timestamp();
    let block_info = get_block_info().unbox();
    hash_u128(block_info.block_number.into(), block_info.block_timestamp.into())
}


//----------------------------------------
// Unit  tests
//
#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use karat::utils::hash::{
        felt_to_u128,
        hash_felt,
        hash_u128,
        make_seed,
        _make_block_hash,
    };


    #[test]
    // #[available_gas(20000)]
    fn test_felt_to_u128() {
        assert(0xab9d03074bff6ee2d4dbc374dbf3f846 == felt_to_u128(0x7f25249bc3b57d4a9cb82bd75d25579ab9d03074bff6ee2d4dbc374dbf3f846), '');
    }

    #[test]
    // #[available_gas(20000)]
    fn test_hash_felt() {
        let rnd0  = hash_felt(25, 1);
        let rnd00 = hash_felt(rnd0, rnd0);
        let rnd1  = hash_felt(25, 1);
        let rnd12 = hash_felt(25, 2);
        let rnd2  = hash_felt(26, 1);
        let rnd22 = hash_felt(26, 2);
        assert(rnd0 == 0x7f25249bc3b57d4a9cb82bd75d25579ab9d03074bff6ee2d4dbc374dbf3f846, '');
        assert(rnd0 != rnd00, '');
        assert(rnd0 == rnd1, '');
        assert(rnd1 != rnd12, '');
        assert(rnd1 != rnd2, '');
        assert(rnd2 != rnd22, '');
    }

    #[test]
    // #[available_gas(20000)]
    fn test_hash_u128() {
        let rnd0  = hash_u128(25, 1);
        let rnd00 = hash_u128(rnd0, rnd0);
        let rnd1  = hash_u128(25, 1);
        let rnd12 = hash_u128(25, 2);
        let rnd2  = hash_u128(26, 1);
        let rnd22 = hash_u128(26, 2);
        // rnd.print();
        assert(rnd0 == 0xab9d03074bff6ee2d4dbc374dbf3f846, '');
        assert(rnd0 != rnd00, '');
        assert(rnd0 == rnd1, '');
        assert(rnd1 != rnd12, '');
        assert(rnd1 != rnd2, '');
        assert(rnd2 != rnd22, '');
    }

    #[test]
    #[available_gas(100_000)]
    fn test__make_block_hash() {
        let h = _make_block_hash();
        assert(h != 0, 'block hash');
    }

    #[test]
    #[available_gas(100_000_000)]
    fn test_make_seed() {
        let s0 = make_seed(0x0);
        let s1 = make_seed(0x1);
        let s2 = make_seed(0x2);
        let s3 = make_seed(0x54f650fb5e1fb61d7b429ae728a365b6);
        let s4 = make_seed(0x19b55e33610cdb4b3ceda054f8870b74);
        assert(s0!=0, 's0');
        assert(s1!=0, 's1');
        assert(s2!=0, 's2');
        assert(s3!=0, 's3');
        assert(s4!=0, 's4');
        assert(s0!=s1, 's0!=s1');
        assert(s1!=s2, 's1!=s2');
        assert(s2!=s3, 's2!=s3');
        assert(s3!=s4, 's3!=s4');
    }
}


