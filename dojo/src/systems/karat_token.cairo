use starknet::{ContractAddress};
use dojo::world::IWorldDispatcher;

#[starknet::interface]
// trait IERC721EnumMintBurnPreset {
trait IKaratToken<TState> {
    // IWorldProvider
    fn world(self: @TState,) -> IWorldDispatcher;

    // ISRC5
    fn supports_interface(self: @TState, interface_id: felt252) -> bool;
    // ISRC5Camel
    fn supportsInterface(self: @TState, interfaceId: felt252) -> bool;

    // IERC721Metadata
    fn name(self: @TState) -> ByteArray;
    fn symbol(self: @TState) -> ByteArray;
    fn token_uri(self: @TState, token_id: u256) -> ByteArray;
    // IERC721MetadataCamel
    fn tokenURI(self: @TState, token_id: u256) -> ByteArray;

    // IERC721Owner
    fn owner_of(self: @TState, token_id: u256) -> ContractAddress;
    // IERC721OwnerCamel
    fn ownerOf(self: @TState, token_id: u256) -> ContractAddress;

    // IERC721Balance
    fn balance_of(self: @TState, account: ContractAddress) -> u256;
    fn transfer_from(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn safe_transfer_from(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
    // IERC721CamelOnly
    fn balanceOf(self: @TState, account: ContractAddress) -> u256;
    fn transferFrom(ref self: TState, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn safeTransferFrom(
        ref self: TState,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );

    // IERC721Approval
    fn get_approved(self: @TState, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    fn approve(ref self: TState, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref self: TState, operator: ContractAddress, approved: bool);
    // IERC721ApprovalCamel
    fn getApproved(self: @TState, token_id: u256) -> ContractAddress;
    fn isApprovedForAll(self: @TState, owner: ContractAddress, operator: ContractAddress) -> bool;
    fn setApprovalForAll(ref self: TState, operator: ContractAddress, approved: bool);

    // IERC721Enumerable
    fn total_supply(self: @TState) -> u256;
    fn token_by_index(self: @TState, index: u256) -> u256;
    fn token_of_owner_by_index(self: @TState, owner: ContractAddress, index: u256) -> u256;
    // IERC721EnumerableCamel
    fn totalSupply(self: @TState) -> u256;
    fn tokenByIndex(self: @TState, index: u256) -> u256;
    fn tokenOfOwnerByIndex(self: @TState, owner: ContractAddress, index: u256) -> u256;

    // karat_token
    fn initialize(
        ref self: TState,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
    );
    fn mint(ref self: TState, to: ContractAddress, token_id: u256);
    fn burn(ref self: TState, token_id: u256);

    //-----------------------------------
    // karat_v1.1
    fn karat_init(ref self: TState);
    // IERC7572ContractMetadata
    fn contract_uri(self: @TState) -> ByteArray;
    // (CamelOnly)
    fn contractURI(self: @TState) -> ByteArray;
    // IERC4906MetadataUpdate
    fn emit_metadata_update(ref self: TState, token_id: u256);
    fn emit_batch_metadata_update(ref self: TState, from_token_id: u256, to_token_id: u256);
    // IERC2981RoyaltyInfo
    fn royalty_info(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    fn default_royalty(self: @TState) -> (ContractAddress, u128, u128);
    fn token_royalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
    // (CamelOnly)
    fn royaltyInfo(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    fn defaultRoyalty(self: @TState) -> (ContractAddress, u128, u128);
    fn tokenRoyalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
}

#[starknet::interface]
trait IKaratTokenNew<TState> {
    fn karat_init(ref self: TState);
    // IERC7572ContractMetadata
    fn contract_uri(self: @TState) -> ByteArray;
    // (CamelOnly)
    fn contractURI(self: @TState) -> ByteArray;
    // IERC4906MetadataUpdate
    fn emit_metadata_update(ref self: TState, token_id: u256);
    fn emit_batch_metadata_update(ref self: TState, from_token_id: u256, to_token_id: u256);
    // IERC2981RoyaltyInfo
    fn default_royalty(self: @TState) -> (ContractAddress, u128, u128);
    fn token_royalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
    fn royalty_info(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
    // (CamelOnly)
    fn defaultRoyalty(self: @TState) -> (ContractAddress, u128, u128);
    fn tokenRoyalty(self: @TState, token_id: u256) -> (ContractAddress, u128, u128);
    fn royaltyInfo(self: @TState, token_id: u256, sale_price: u256) -> (ContractAddress, u256);
}

#[starknet::interface]
trait IERC721EnumMintBurn<TState> {
    fn mint(ref self: TState, to: ContractAddress, token_id: u256);
    fn burn(ref self: TState, token_id: u256);
}

#[dojo::contract]
mod karat_token {
    use debug::PrintTrait;
    use starknet::ContractAddress;
    use starknet::{get_contract_address, get_caller_address};

    use karat::systems::minter::{IRenderer, IRendererDispatcher, IRendererDispatcherTrait};
    use karat::models::config::{Config, ConfigTrait};
    use karat::models::token_data::{ContractData};
    use karat::models::constants::{CONST};
    use karat::utils::renderer::{renderer};

    use origami_token::components::security::initializable::initializable_component;
    use origami_token::components::introspection::src5::src5_component;
    use origami_token::components::token::erc721::erc721_approval::erc721_approval_component;
    use origami_token::components::token::erc721::erc721_balance::erc721_balance_component;
    use origami_token::components::token::erc721::erc721_burnable::erc721_burnable_component;
    use origami_token::components::token::erc721::erc721_enumerable::erc721_enumerable_component;
    use origami_token::components::token::erc721::erc721_metadata::erc721_metadata_component;
    use origami_token::components::token::erc721::erc721_mintable::erc721_mintable_component;
    use origami_token::components::token::erc721::erc721_owner::erc721_owner_component;

    component!(path: initializable_component, storage: initializable, event: InitializableEvent);
    component!(path: src5_component, storage: src5, event: SRC5Event);
    component!(path: erc721_approval_component, storage: erc721_approval, event: ERC721ApprovalEvent);
    component!(path: erc721_balance_component, storage: erc721_balance, event: ERC721BalanceEvent);
    component!(path: erc721_burnable_component, storage: erc721_burnable, event: ERC721BurnableEvent);
    component!(path: erc721_enumerable_component, storage: erc721_enumerable, event: ERC721EnumerableEvent);
    component!(path: erc721_mintable_component, storage: erc721_mintable, event: ERC721MintableEvent);
    component!(path: erc721_owner_component, storage: erc721_owner, event: ERC721OwnerEvent);
    component!(path: erc721_metadata_component, storage: erc721_metadata, event: ERC721MetadataEvent);

    impl InitializableImpl = initializable_component::InitializableImpl<ContractState>;
    #[abi(embed_v0)]
    impl SRC5Impl = src5_component::SRC5Impl<ContractState>;
    impl SRC5InternalImpl = src5_component::InternalImpl<ContractState>;
    #[abi(embed_v0)]
    impl SRC5CamelImpl = src5_component::SRC5CamelImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721ApprovalImpl = erc721_approval_component::ERC721ApprovalImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721ApprovalCamelImpl = erc721_approval_component::ERC721ApprovalCamelImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721BalanceImpl = erc721_balance_component::ERC721BalanceImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721BalanceCamelImpl = erc721_balance_component::ERC721BalanceCamelImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721EnumerableImpl = erc721_enumerable_component::ERC721EnumerableImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721EnumerableCamelImpl = erc721_enumerable_component::ERC721EnumerableCamelImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataImpl = erc721_metadata_component::ERC721MetadataImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataCamelImpl = erc721_metadata_component::ERC721MetadataCamelImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721OwnerImpl = erc721_owner_component::ERC721OwnerImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721OwnerCamelImpl = erc721_owner_component::ERC721OwnerCamelImpl<ContractState>;

    //
    // Internal Impls
    //    
    impl InitializableInternalImpl = initializable_component::InternalImpl<ContractState>;
    impl ERC721ApprovalInternalImpl = erc721_approval_component::InternalImpl<ContractState>;
    impl ERC721BalanceInternalImpl = erc721_balance_component::InternalImpl<ContractState>;
    impl ERC721BurnableInternalImpl = erc721_burnable_component::InternalImpl<ContractState>;
    impl ERC721EnumerableInternalImpl = erc721_enumerable_component::InternalImpl<ContractState>;
    impl ERC721MetadataInternalImpl = erc721_metadata_component::InternalImpl<ContractState>;
    impl ERC721MintableInternalImpl = erc721_mintable_component::InternalImpl<ContractState>;
    impl ERC721OwnerInternalImpl = erc721_owner_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        #[substorage(v0)]
        initializable: initializable_component::Storage,
        #[substorage(v0)]
        src5: src5_component::Storage,
        #[substorage(v0)]
        erc721_approval: erc721_approval_component::Storage,
        #[substorage(v0)]
        erc721_balance: erc721_balance_component::Storage,
        #[substorage(v0)]
        erc721_burnable: erc721_burnable_component::Storage,
        #[substorage(v0)]
        erc721_enumerable: erc721_enumerable_component::Storage,
        #[substorage(v0)]
        erc721_metadata: erc721_metadata_component::Storage,
        #[substorage(v0)]
        erc721_mintable: erc721_mintable_component::Storage,
        #[substorage(v0)]
        erc721_owner: erc721_owner_component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        InitializableEvent: initializable_component::Event,
        #[flat]
        SRC5Event: src5_component::Event,
        #[flat]
        ERC721ApprovalEvent: erc721_approval_component::Event,
        #[flat]
        ERC721BalanceEvent: erc721_balance_component::Event,
        #[flat]
        ERC721BurnableEvent: erc721_burnable_component::Event,
        #[flat]
        ERC721EnumerableEvent: erc721_enumerable_component::Event,
        #[flat]
        ERC721MetadataEvent: erc721_metadata_component::Event,
        #[flat]
        ERC721MintableEvent: erc721_mintable_component::Event,
        #[flat]
        ERC721OwnerEvent: erc721_owner_component::Event,
        // karat_v1.1
        ContractURIUpdated: ContractURIUpdated,
        MetadataUpdate: MetadataUpdate,
        BatchMetadataUpdate: BatchMetadataUpdate,
    }

    // karat_v1.1
    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct ContractURIUpdated {}
    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct MetadataUpdate {
        #[key]
        pub token_id: u256,
    }
    #[derive(Drop, PartialEq, starknet::Event)]
    pub struct BatchMetadataUpdate {
        #[key]
        pub from_token_id: u256,
        #[key]
        pub to_token_id: u256,
    }
    pub const ROYALTY_FEE_DENOMINATOR: u128 = 10_000;

    mod Errors {
        const CALLER_IS_NOT_OWNER: felt252      = 'KARAT: caller is not owner';
        const CALLER_IS_NOT_MINTER: felt252     = 'KARAT: caller is not minter';
    }

    fn dojo_init(ref self: ContractState) {
        self.erc721_metadata.initialize(
            CONST::const_string(CONST::TOKEN_NAME),
            CONST::const_string(CONST::TOKEN_SYMBOL),
            CONST::const_string(CONST::BASE_URI),
        );
        self.erc721_enumerable.initialize();
        self.initializable.initialize();
        // karat_v1.1
        self._init();
    }

    #[abi(embed_v0)]
    impl EnumMintBurnImpl of super::IERC721EnumMintBurn<ContractState> {
        fn mint(
            ref self: ContractState,
            to: ContractAddress,
            token_id: u256,
        ) {
            let config: Config = get!(self.world(), (get_contract_address()), Config);
            assert(config.is_minter(get_caller_address()), Errors::CALLER_IS_NOT_MINTER);
            self.erc721_mintable.mint(to, token_id);
        }
        fn burn(
            ref self: ContractState,
            token_id: u256,
        ) {
            self.erc721_burnable.burn(token_id);
        }
    }

    //
    // Metadata Hooks
    //
    use super::{IKaratTokenDispatcher, IKaratTokenDispatcherTrait};
    impl ERC721MetadataHooksImpl<ContractState> of erc721_metadata_component::ERC721MetadataHooksTrait<ContractState> {
        fn custom_uri(
            self: @erc721_metadata_component::ComponentState<ContractState>,
            base_uri: @ByteArray,
            token_id: u256,
        ) -> ByteArray {
            let contract_address = get_contract_address();
            let selfie = IKaratTokenDispatcher{ contract_address };
            let world = selfie.world();
            // call renderer
            let config: Config = get!(world, (contract_address), Config);
            let renderer = IRendererDispatcher{ contract_address: config.renderer_address };
            (renderer.render_uri(token_id.low))
        }
    }

    //---------------------------------------
    // karat_v1.1
    //
    #[abi(embed_v0)]
    impl KaratTokenNewImpl of super::IKaratTokenNew<ContractState> {

        fn karat_init(ref self: ContractState) {
            self._assert_caller_is_owner();
            self._init();
        }

        //---------------------------------------
        // IERC7572ContractMetadata
        //
        fn contract_uri(self: @ContractState) -> ByteArray {
            let contract_data = ContractData{
                name: CONST::const_string(CONST::TOKEN_NAME),
                symbol: CONST::const_string(CONST::TOKEN_SYMBOL),
                description: CONST::const_string(CONST::METADATA_DESCRIPTION),
                external_link: CONST::const_string(CONST::EXTERNAL_LINK),
                image: CONST::CONTRACT_IMAGE(),
            };
            (renderer::build_contract_uri(contract_data))
        }
        // (CamelOnly)
        fn contractURI(self: @ContractState) -> ByteArray {
            (self.contract_uri())
        }

        //---------------------------------------
        // IERC4906MetadataUpdate
        //
        fn emit_metadata_update(ref self: ContractState, token_id: u256) {
            self.emit(MetadataUpdate {
                token_id,
            });
        }
        fn emit_batch_metadata_update(ref self: ContractState, from_token_id: u256, to_token_id: u256) {
            self.emit(BatchMetadataUpdate {
                from_token_id,
                to_token_id,
            });
        }

        //---------------------------------------
        // IERC2981RoyaltyInfo
        //
        fn default_royalty(self: @ContractState) -> (ContractAddress, u128, u128) {
            let config: Config = get!(self.world(), (get_contract_address()), Config);
            (config.royalty_receiver, config.royalty_fraction, ROYALTY_FEE_DENOMINATOR)
        }
        fn token_royalty(self: @ContractState, token_id: u256) -> (ContractAddress, u128, u128) {
            let config: Config = get!(self.world(), (get_contract_address()), Config);
            (config.royalty_receiver, config.royalty_fraction, ROYALTY_FEE_DENOMINATOR)
        }
        fn royalty_info(self: @ContractState, token_id: u256, sale_price: u256) -> (ContractAddress, u256) {
            let config: Config = get!(self.world(), (get_contract_address()), Config);
            let royalty_amount: u256 = sale_price
                * config.royalty_fraction.into()
                / ROYALTY_FEE_DENOMINATOR.into();
            (config.royalty_receiver, royalty_amount)
        }
        // (CamelOnly)
        fn defaultRoyalty(self: @ContractState) -> (ContractAddress, u128, u128) {
            (self.default_royalty())
        }
        fn tokenRoyalty(self: @ContractState, token_id: u256) -> (ContractAddress, u128, u128) {
            (self.token_royalty(token_id))
        }
        fn royaltyInfo(self: @ContractState, token_id: u256, sale_price: u256) -> (ContractAddress, u256) {
            (self.royalty_info(token_id, sale_price))
        }
    }

    //
    // Internal Impls
    //
    #[generate_trait]
    impl InternalImpl of InternalTrait {
        #[inline(always)]
        fn _assert_caller_is_owner(self: @ContractState) {
            assert(self._caller_is_owner(), Errors::CALLER_IS_NOT_OWNER);
        }
        #[inline(always)]
        fn _caller_is_owner(self: @ContractState) -> bool {
            (self.world().is_owner(self.selector().into(), get_caller_address()))
        }
        fn _init(ref self: ContractState) {
            self.src5.register_interface(karat::interfaces::erc721::IERC7572_ID);
            self.src5.register_interface(karat::interfaces::erc721::IERC4906_ID);
            self.src5.register_interface(karat::interfaces::erc721::IERC2981_ID);
            self.emit(ContractURIUpdated {});
        }
    }
}
