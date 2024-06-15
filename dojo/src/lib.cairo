mod systems {
    mod actions;
    mod metadata;
}

mod models {
    mod moves;
    mod position;
}

#[cfg(test)]
mod tests {
    mod test_world;

    mod token {
        mod test_erc721_approval;
        mod test_erc721_balance;
        mod test_erc721_enumerable;
        mod test_erc721_metadata;
        mod test_erc721_mintable_burnable;
        mod erc721_metadata_mock;
    }
}
