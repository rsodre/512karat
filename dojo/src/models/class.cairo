use traits::{Into, PartialOrd};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum Class {
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
}
const CLASS_COUNT: u128 = 8;

trait ClassTrait {
    fn from_seed(seed: u128) -> Class;
    fn to_charset(self: Class) -> felt252;
    fn to_bytes(self: Class) -> ByteArray;
    fn to_char_array(self: Class) -> Span<ByteArray>;
}

impl ClassTraitImpl of ClassTrait {
    fn from_seed(seed: u128) -> Class {
        (seed.into())
    }
    fn to_charset(self: Class) -> felt252 {
        match self {
            Class::A => 'Aa.__', // '╰╯╭╮',
            Class::B => 'Bb.__', // '╰╯╭╮^._',
            Class::C => 'Cc.__',
            Class::D => 'Dd.__',
            Class::E => 'Ee.__',
            Class::F => 'Ff.__',
            Class::G => 'Gg.__',
            Class::H => 'Hh.__',
        }
    }
    fn to_bytes(self: Class) -> ByteArray {
        match self {
            Class::A => "Aa.__", // "╰╯╭╮",
            Class::B => "Bb.__", // "╰╯╭╮^._",
            Class::C => "Cc.__",
            Class::D => "Dd.__",
            Class::E => "Ee.__",
            Class::F => "Ff.__",
            Class::G => "Gg.__",
            Class::H => "Hh.__",
        }
    }
    fn to_char_array(self: Class) -> Span<ByteArray> {
        match self {
            Class::A => array!["&#E297A3;", "A", ".", "_", "_"].span(),
            Class::B => array!["&#E297A3;", "B", ".", "_", "_"].span(),
            Class::C => array!["&#E297A3;", "C", ".", "_", "_"].span(),
            Class::D => array!["&#E297A3;", "D", ".", "_", "_"].span(),
            Class::E => array!["&#E297A3;", "E", ".", "_", "_"].span(),
            Class::F => array!["&#E297A3;", "F", ".", "_", "_"].span(),
            Class::G => array!["&#E297A3;", "H", ".", "_", "_"].span(),
            Class::H => array!["&#E297A3;", "I", ".", "_", "_"].span(),
        }
    }
}


impl ClassIntoU128 of Into<Class, u128> {
    fn into(self: Class) -> u128 {
        match self {
            Class::A => 0,
            Class::B => 1,
            Class::C => 2,
            Class::D => 3,
            Class::E => 4,
            Class::F => 5,
            Class::G => 6,
            Class::H => 7,
        }
    }
}
impl U128IntoClass of Into<u128, Class> {
    fn into(self: u128) -> Class {
        let s = (self % CLASS_COUNT);
        if s == 0 { Class::A }
        else if s == 1 { Class::B }
        else if s == 2 { Class::C }
        else if s == 3 { Class::D }
        else if s == 4 { Class::E }
        else if s == 5 { Class::F }
        else if s == 6 { Class::G }
        else if s == 7 { Class::H }
        else  { Class::A }
    }
}