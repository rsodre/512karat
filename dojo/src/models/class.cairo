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
const CHAR_COUNT: usize = 5;

trait ClassTrait {
    fn name(self: Class) -> ByteArray;
    fn to_char_array(self: Class) -> Span<ByteArray>;
}

impl ClassTraitImpl of ClassTrait {
    fn name(self: Class) -> ByteArray {
        match self {
            Class::A => "A", // "╰╯╭╮",
            Class::B => "B", // "╰╯╭╮^._",
            Class::C => "C",
            Class::D => "D",
            Class::E => "E",
            Class::F => "F",
            Class::G => "G",
            Class::H => "H",
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


// impl ClassIntoU128 of Into<Class, u128> {
//     fn into(self: Class) -> u128 {
//         match self {
//             Class::A => 0,
//             Class::B => 1,
//             Class::C => 2,
//             Class::D => 3,
//             Class::E => 4,
//             Class::F => 5,
//             Class::G => 6,
//             Class::H => 7,
//         }
//     }
// }
// impl U128IntoClass of Into<u128, Class> {
//     fn into(self: u128) -> Class {
//         let s = (self % CLASS_COUNT);
//         if s == 0 { Class::A }
//         else if s == 1 { Class::B }
//         else if s == 2 { Class::C }
//         else if s == 3 { Class::D }
//         else if s == 4 { Class::E }
//         else if s == 5 { Class::F }
//         else if s == 6 { Class::G }
//         else if s == 7 { Class::H }
//         else  { Class::A }
//     }
// }







//----------------------------
// tests
//
#[cfg(test)]
mod tests {
    use super::{Class, ClassTrait, CLASS_COUNT, CHAR_COUNT};
    use karat::models::seed::{Seed, SeedTrait};

    #[test]
    #[available_gas(100_000_000)]
    fn test_class_arrya_sizes() {
        let mut c: u128 = 0;
        loop {
            if (c == CLASS_COUNT) {
                break;
            }
            let seed: Seed = Seed{ token_id:1, seed:(0x57237+c) };
            let class: Class = seed.to_class();
            assert(class.to_char_array().len() == CHAR_COUNT, 'not char len');
            c += 1;
        };
    }
}
