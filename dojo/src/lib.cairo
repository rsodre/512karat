mod systems {
    mod karat_token;
    mod metadata;
    mod minter;
}

mod models {
    mod class;
    mod config;
    mod seed;
    mod token_data;
}

mod utils {
    mod encoding;
    mod hash;
    mod painter;
}

mod tests {
    mod tester;
    mod test_minter;

    mod token {
        #[cfg(test)]
        mod test_erc721_approval;
        #[cfg(test)]
        mod test_erc721_balance;
        #[cfg(test)]
        mod test_erc721_enumerable;
        #[cfg(test)]
        mod test_erc721_metadata;
        #[cfg(test)]
        mod test_erc721_mintable_burnable;
        // mod erc721_metadata_mock;
    }
}
