use traits::{Into, PartialOrd};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum Class {
    A,
    B,
    C,
    D,
    E,
    L,
}
const CLASS_COUNT: u128 = 6;

trait ClassTrait {
    fn name(self: Class) -> ByteArray;
    fn get_char_set(self: Class) -> Span<felt252>;
    fn is_scaled(self: Class) -> bool;
}

impl ClassTraitImpl of ClassTrait {
    fn name(self: Class) -> ByteArray {
        match self {
            Class::A => "A",
            Class::B => "B",
            Class::C => "C",
            Class::D => "D",
            Class::E => "E",
            Class::L => "L",
        }
    }
    fn get_char_set(self: Class) -> Span<felt252> {
        match self {
            Class::A => array!['&#x0020;', '&#x002E;', '&#x007C;', '&#x007C;', '&#x002F;', '&#x002F;', '&#x005C;', '&#x005C;', '&#x25C6;', '&#x25C7;'].span(), 
            Class::B => array!['&#x26AB;', '&#x2B55;', '&#x26D4;', '&#x26BE;', '&#x26BD;', '&#x26AA;', '&#x270A;', '&#x274E;'].span(), 
            Class::C => array!['&#x25AB;', '&#x25A2;', '&#x25A4;', '&#x25A5;', '&#x25A9;', '&#x2CBC;', '&#x2705;'].span(), 
            Class::D => array!['&#x274C;', '&#x0020;', '&#x0020;', '&#x002E;', '&#x002E;', '&#x25C7;', '&#x25C7;', '&#x25C6;', '&#x25E2;', '&#x25E4;', '&#x25E5;', '&#x25E3;', '&#x25C0;', '&#x25B6;', '&#x2D54;'].span(), 
            Class::E => array!['&#x2595;', '&#x2595;', '&#x2594;', '&#x2594;', '&#x2597;', '&#x259D;', '&#x2596;', '&#x2598;', '&#x002F;', '&#x005C;', '&#x259A;', '&#x259E;'].span(), 
            Class::L => array!['&#x0020;', '&#x002E;', '&#x002E;', '&#x002D;', '&#x002D;', '&#x007C;', '&#x007C;', '&#x2B50;', '&#x0074;', '&#x006F;', '&#x006F;', '&#x004C;', '&#x007C;'].span(),
        }
    }
    fn is_scaled(self: Class) -> bool {
        match self {
            Class::A => true,
            Class::B => false,
            Class::C => false,
            Class::D => false,
            Class::E => true,
            Class::L => false,
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
//             Class::L => 5,
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
//         else if s == 5 { Class::L }
//         else  { Class::A }
//     }
// }







//----------------------------
// tests
//
#[cfg(test)]
mod tests {
    use super::{Class, ClassTrait, CLASS_COUNT};
    use karat::models::seed::{Seed, SeedTrait};

    // #[test]
    // #[available_gas(100_000_000)]
    // fn test_class_array_sizes() {
    //     let mut c: u128 = 0;
    //     loop {
    //         if (c == CLASS_COUNT) {
    //             break;
    //         }
    //         let seed: Seed = Seed{ token_id:1, seed:(0x57237+c) };
    //         let class: Class = seed.to_class();
    //         assert(class.get_char_set().len() == CHAR_COUNT, 'not char len');
    //         c += 1;
    //     };
    // }
}
