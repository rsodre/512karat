use karat::utils::hash::{make_seed};

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Seed {
    #[key]
    token_id: u128,
    seed: u128,
}

#[generate_trait]
impl SeedTraitImpl of SeedTrait {
    fn new(token_id: u128) -> Seed {
        let seed = make_seed(token_id);
        (Seed{
            token_id,
            seed,
        })
    }
}


 
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
