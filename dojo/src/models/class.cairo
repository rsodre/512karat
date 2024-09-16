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
    fn get_char_set_sizes(self: Class) -> Span<usize>;
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
            Class::A => array!['&#32;', '&#46;', '&#124;', '&#124;', '&#47;', '&#47;', '&#92;', '&#92;', '&#9670;', '&#9671;'].span(), 
            Class::B => array!['&#9899;', '&#11093;', '&#9940;', '&#9918;', '&#9917;', '&#9898;', '&#9994;', '&#10062;'].span(), 
            Class::C => array!['&#9643;', '&#9634;', '&#9636;', '&#9637;', '&#9641;', '&#11452;', '&#9989;'].span(), 
            Class::D => array!['&#10060;', '&#124;', '&#46;', '&#46;', '&#32;', '&#9671;', '&#9671;', '&#9670;', '&#9698;', '&#9700;', '&#9701;', '&#9699;', '&#9664;', '&#9654;', '&#11604;'].span(), 
            Class::E => array!['&#9621;', '&#9621;', '&#9620;', '&#9620;', '&#9623;', '&#9629;', '&#9622;', '&#9624;', '&#9626;', '&#9630;', '&#9625;', '&#9620;', '&#9620;'].span(), 
            Class::L => array!['&#32;', '&#46;', '&#45;', '&#124;', '&#11088;', '&#116;', '&#111;', '&#111;', '&#76;', '&#124;', '&#10060;'].span(), 
        }
    }
    fn get_char_set_sizes(self: Class) -> Span<usize> {
        match self {
            Class::A => array![5, 5, 6, 6, 5, 5, 5, 5, 7, 7].span(), 
            Class::B => array![7, 8, 7, 7, 7, 7, 7, 8].span(), 
            Class::C => array![7, 7, 7, 7, 7, 8, 7].span(), 
            Class::D => array![8, 6, 5, 5, 5, 7, 7, 7, 7, 7, 7, 7, 7, 7, 8].span(), 
            Class::E => array![7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7].span(), 
            Class::L => array![5, 5, 5, 6, 8, 6, 6, 6, 5, 6, 8].span(),
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
    //         let class: Class = seed.get_class();
    //         assert(class.get_char_set().len() == CHAR_COUNT, 'not char len');
    //         c += 1;
    //     };
    // }
}
