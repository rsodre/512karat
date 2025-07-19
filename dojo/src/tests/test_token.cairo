#[cfg(test)]
mod tests {
    use debug::PrintTrait;
    use starknet::{ContractAddress, testing};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    // token
    use origami_token::tests::constants::{ZERO, OWNER, OTHER, TOKEN_ID_2, TOKEN_ID_3};
    use origami_token::components::introspection::src5::{ISRC5_ID};
    use origami_token::components::token::erc721::interface::{IERC721_ID, IERC721_METADATA_ID};
    use origami_token::tests::utils;

    // karat
    use karat::{
        systems::{minter::{minter, IMinterDispatcher, IMinterDispatcherTrait}},
        systems::{karat_token::{karat_token, IKaratTokenDispatcher, IKaratTokenDispatcherTrait}},
        models::config::{Config, ConfigTrait},
        models::seed::{Seed, SeedTrait},
        models::constants::{CONST},
        utils::misc::{WEI, ETH},
    };

    use karat::tests::tester::{tester, tester::{ Systems }};

    fn TREASURY() -> ContractAddress {(starknet::contract_address_const::<0x1234>())}
    
    pub const DEFAULT_DENOMINATOR: u128 = 10_000;
    pub const DEFAULT_FEE: u128 = 500;

    fn _karat_init(sys: Systems) {
        sys.karat.karat_init();
        sys.minter.set_royalty(sys.karat.contract_address, TREASURY(), DEFAULT_FEE);
        // sys.minter.set_purchase_price(sys.karat.contract_address, STRK(), WEI(100));
    }

    #[test]
    fn test_is_initialized() {
        let sys: Systems = tester::spawn_systems(false);
        println!("NAME: {}", sys.karat.name());
        println!("SYMBOL: {}", sys.karat.symbol());
        assert(sys.karat.name() == CONST::const_string(CONST::TOKEN_NAME), 'name');
        assert(sys.karat.symbol() == CONST::const_string(CONST::TOKEN_SYMBOL), 'symbol');
        assert!(sys.karat.supports_interface(ISRC5_ID), "should support ISRC5_ID");
        assert!(sys.karat.supports_interface(IERC721_ID), "should support IERC721_ID");
        assert!(sys.karat.supports_interface(IERC721_METADATA_ID), "should support METADATA");
        assert!(sys.karat.supports_interface(karat::interfaces::erc721::IERC7572_ID), "should support IERC7572_ID");
        assert!(sys.karat.supports_interface(karat::interfaces::erc721::IERC4906_ID), "should support IERC4906_ID");
        assert!(sys.karat.supports_interface(karat::interfaces::erc721::IERC2981_ID), "should support IERC2981_ID");
    }

    #[test]
    fn test_token_uri() {
        let sys: Systems = tester::spawn_systems(false);
        sys.minter.mint(sys.karat.contract_address);
        let uri: ByteArray = sys.karat.token_uri(1);
        let uri_camel = sys.karat.tokenURI(1);
// println!("___contract_uri_none(1):[{}]", uri);
        assert!(uri.len() > 0, "contract_uri() should not be empty");
        assert!(uri == uri_camel, "contractURI() == contract_uri()");
        assert!(tester::starts_with(uri, "data:"), "contract_uri() should be a json string");
    }

    #[test]
    fn test_admin_karat_init_ok() {
        let sys: Systems = tester::spawn_systems(false);
        tester::impersonate(OWNER());
        sys.karat.karat_init();
        assert!(sys.karat.supports_interface(karat::interfaces::erc721::IERC7572_ID), "should support IERC7572_ID");
        assert!(sys.karat.supports_interface(karat::interfaces::erc721::IERC4906_ID), "should support IERC4906_ID");
        assert!(sys.karat.supports_interface(karat::interfaces::erc721::IERC2981_ID), "should support IERC2981_ID");
        // must emit contract metadata event
        let _event = tester::pop_log::<karat_token::ContractURIUpdated>(sys.karat.contract_address, selector!("ContractURIUpdated")).unwrap();
    }

    #[test]
    #[should_panic(expected:('KARAT: caller is not owner','ENTRYPOINT_FAILED'))]
    fn test_admin_karat_init_not_owner() {
        let sys: Systems = tester::spawn_systems(false);
        tester::impersonate(OTHER());
        sys.karat.karat_init();
    }


    //
    // contract_uri
    //

    #[test]
    fn test_contract_uri() {
        let sys: Systems = tester::spawn_systems(false);
        let uri: ByteArray = sys.karat.contract_uri();
        let uri_camel = sys.karat.contractURI();
// println!("___contract_uri: [{}]", uri);
        assert_ne!(uri, "", "contract_uri() should not be empty");
        assert_eq!(uri, uri_camel, "contractURI() == contract_uri()");
        assert!(tester::starts_with(uri, "data:"), "contract_uri() should be a json string");
    }


    //
    // metadata_update
    //

    #[test]
    fn test_metadata_update() {
        let sys: Systems = tester::spawn_systems(false);
        tester::drop_all_events(sys.karat.contract_address);
        sys.karat.emit_metadata_update(TOKEN_ID_3);
        let event = tester::pop_log::<karat_token::MetadataUpdate>(sys.karat.contract_address, selector!("MetadataUpdate")).unwrap();
        assert_eq!(event.token_id, TOKEN_ID_3, "event.token_id");
    }

    #[test]
    fn test_batch_metadata_update() {
        let sys: Systems = tester::spawn_systems(false);
        tester::drop_all_events(sys.karat.contract_address);
        sys.karat.emit_batch_metadata_update(TOKEN_ID_2, TOKEN_ID_3);
        let event = tester::pop_log::<karat_token::BatchMetadataUpdate>(sys.karat.contract_address, selector!("BatchMetadataUpdate")).unwrap();
        assert_eq!(event.from_token_id, TOKEN_ID_2, "event.from_token_id");
        assert_eq!(event.to_token_id, TOKEN_ID_3, "event.to_token_id");
    }


    //
    // royalty_info
    //

    #[test]
    fn test_default_royalty() {
        let sys: Systems = tester::spawn_systems(false);
        // default is zero
        let (receiver, numerator, denominator) = sys.karat.default_royalty();
        assert_eq!(receiver, ZERO(), "default: receiver");
        assert_eq!(numerator, 0, "default: numerator");
        assert_eq!(denominator, DEFAULT_DENOMINATOR, "default: denominator");
        // set
        _karat_init(sys);
        let (receiver, numerator, denominator) = sys.karat.default_royalty();
        assert_eq!(receiver, TREASURY(), "set: wrong receiver");
        assert_eq!(numerator, DEFAULT_FEE, "set: wrong numerator");
        assert_eq!(denominator, DEFAULT_DENOMINATOR, "set: denominator");
    }

    #[test]
    fn test_token_royalty() {
        let sys: Systems = tester::spawn_systems(false);
        // default is zero
        let (receiver, numerator, denominator) = sys.karat.token_royalty(1);
        assert_eq!(receiver, ZERO(), "default: receiver");
        assert_eq!(numerator, 0, "default: numerator");
        assert_eq!(denominator, DEFAULT_DENOMINATOR, "default: denominator");
        // set
        _karat_init(sys);
        let (receiver, numerator, denominator) = sys.karat.token_royalty(1);
        assert_eq!(receiver, TREASURY(), "set: wrong receiver");
        assert_eq!(numerator, DEFAULT_FEE, "set: wrong numerator");
        assert_eq!(denominator, DEFAULT_DENOMINATOR, "set: denominator");
    }

    #[test]
    fn test_royalty_info() {
        let sys: Systems = tester::spawn_systems(false);
        // default is zero
        let PRICE: u256 = WEI(100); // 100 ETH
        let (receiver, fees) = sys.karat.royalty_info(1, PRICE);
        assert_eq!(receiver, ZERO(), "default: receiver");
        assert_eq!(fees, 0, "default: fees");
        // set
        _karat_init(sys);
        let (receiver, fees) = sys.karat.royalty_info(1, PRICE);
        assert_eq!(receiver, TREASURY(), "set: wrong receiver");
        assert_eq!(fees, WEI(5), "set: wrong fees"); // default 5%
    }

}
