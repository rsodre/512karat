mod CONST {
    const TOKEN_NAME: felt252 = 'Karat';
    const TOKEN_SYMBOL: felt252 = 'KARAT';
    const BASE_URI: felt252 = 'https://karat.collect-code.com/';
    const METADATA_DESCRIPTION: felt252 = 'Gemstones for composable lore';

    // use the getter to avoid using the felt numerical value instead
    use karat::utils::short_string::{ShortStringTrait};
    fn const_string(const_name: felt252) -> ByteArray {
        (const_name.string())
    }
}
