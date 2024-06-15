mod systems {
    mod actions;
    mod karat_token;
    mod metadata;
}

mod models {
    mod moves;
    mod position;
}

mod tests {
    mod tester;
    mod test_karat_mint;
    mod test_world;

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
        mod erc721_metadata_mock;
    }
}
