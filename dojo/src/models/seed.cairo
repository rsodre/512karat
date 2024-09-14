use karat::utils::hash::{make_seed};
use karat::{
    models::class::{Class, ClassTrait, CLASS_COUNT},
};

#[dojo::model]
#[derive(Copy, Drop, Serde)]
pub struct Seed {
    #[key]
    pub token_id: u128,
    pub seed: u128,
}

trait SeedTrait {
    fn new(token_id: u128) -> Seed;
    fn to_class(self: Seed) -> Class;
    fn realm_id(self: Seed) -> felt252;
}

impl SeedTraitImpl of SeedTrait {
    fn new(token_id: u128) -> Seed {
        let seed = make_seed(token_id);
        (Seed { token_id, seed })
    }
    fn to_class(self: Seed) -> Class {
        let s: u128 = (self.seed % CLASS_COUNT);
        if (s == 0) { Class::A }
        else if (s == 1) { Class::B }
        else if (s == 2) { Class::C }
        else if (s == 3) { Class::D }
        else if (s == 4) { Class::E }
        else if (s == 5) { Class::L }
        else  { Class::A }
    }
    fn realm_id(self: Seed) -> felt252 {
        ((self.seed % 8_000).into() + 1)
    }
}





//----------------------------
// tests
//
#[cfg(test)]
mod tests {
    use super::{Seed, SeedTrait};

    #[test]
    #[available_gas(100000)]
    fn test_seed_is_unique() {
        let seed_1 = SeedTrait::new(1);
        let seed_2 = SeedTrait::new(2);
        let seed_1b = SeedTrait::new(1);
        assert(seed_1.seed > 0, 'seed_1');
        assert(seed_2.seed > 0, 'seed_2');
        assert(seed_1.seed != seed_2.seed, 'seed_1_2');
        assert(seed_1.seed == seed_1b.seed, 'seed_1_1');
    }
}
