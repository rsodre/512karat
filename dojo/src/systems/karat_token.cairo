use starknet::{ContractAddress, ClassHash};
use dojo::world::IWorldDispatcher;

#[dojo::interface]
// trait IERC721EnumMintBurnPreset {
trait IKaratToken {

    // IERC721Approval
    fn get_approved(world: @IWorldDispatcher, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(world: @IWorldDispatcher, owner: ContractAddress, operator: ContractAddress) -> bool;
    fn approve(ref world: IWorldDispatcher, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref world: IWorldDispatcher, operator: ContractAddress, approved: bool);

    // IERC721Balance
    fn balance_of(world: @IWorldDispatcher, account: ContractAddress) -> u256;
    fn transfer_from(ref world: IWorldDispatcher, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn safe_transfer_from(
        ref world: IWorldDispatcher,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );

    // IERC721Owner
    fn owner_of(world: @IWorldDispatcher, token_id: u256) -> ContractAddress;

    // IERC721Enumerable
    fn total_supply(world: @IWorldDispatcher) -> u256;
    fn token_by_index(world: @IWorldDispatcher, index: u256) -> u256;
    fn token_of_owner_by_index(world: @IWorldDispatcher, owner: ContractAddress, index: u256) -> u256;

    // IERC721Metadata
    fn name(world: @IWorldDispatcher) -> ByteArray;
    fn symbol(world: @IWorldDispatcher) -> ByteArray;
    fn token_uri(world: @IWorldDispatcher, token_id: u256) -> ByteArray;
    // IERC721MetadataCamel
    fn tokenURI(world: @IWorldDispatcher, token_id: u256) -> ByteArray;

    // karat_token
    fn initialize(
        ref world: IWorldDispatcher,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
    );
    fn mint(ref world: IWorldDispatcher, to: ContractAddress, token_id: u256);
    fn burn(ref world: IWorldDispatcher, token_id: u256);
}

// extends IERC721Balance
#[dojo::interface]
trait IERC721EnumTransfer {
    fn balance_of(world: @IWorldDispatcher, account: ContractAddress) -> u256;
    fn transfer_from(ref world: IWorldDispatcher, from: ContractAddress, to: ContractAddress, token_id: u256);
    fn safe_transfer_from(
        ref world: IWorldDispatcher,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
}

#[dojo::interface]
trait IERC721EnumMintBurn {
    fn mint(ref world: IWorldDispatcher, to: ContractAddress, token_id: u256);
    fn burn(ref world: IWorldDispatcher, token_id: u256);
}

#[dojo::interface]
trait IERC721EnumInit {
    fn initialize(
        ref world: IWorldDispatcher,
        name: ByteArray,
        symbol: ByteArray,
        base_uri: ByteArray,
    );
}

#[dojo::contract(allow_ref_self)]
mod karat_token {
    use debug::PrintTrait;
    use starknet::ContractAddress;
    use starknet::{get_contract_address, get_caller_address};

    use karat::models::config::{Config, ConfigTrait, ConfigManager, ConfigManagerTrait};

    use token::components::security::initializable::initializable_component;
    use token::components::token::erc721::erc721_approval::erc721_approval_component;
    use token::components::token::erc721::erc721_balance::erc721_balance_component;
    use token::components::token::erc721::erc721_burnable::erc721_burnable_component;
    use token::components::token::erc721::erc721_enumerable::erc721_enumerable_component;
    use token::components::token::erc721::erc721_mintable::erc721_mintable_component;
    use token::components::token::erc721::erc721_owner::erc721_owner_component;
    use karat::systems::metadata::erc721_metadata_component;

    component!(path: initializable_component, storage: initializable, event: InitializableEvent);
    component!(path: erc721_approval_component, storage: erc721_approval, event: ERC721ApprovalEvent);
    component!(path: erc721_balance_component, storage: erc721_balance, event: ERC721BalanceEvent);
    component!(path: erc721_burnable_component, storage: erc721_burnable, event: ERC721BurnableEvent);
    component!(path: erc721_enumerable_component, storage: erc721_enumerable, event: ERC721EnumerableEvent);
    component!(path: erc721_mintable_component, storage: erc721_mintable, event: ERC721MintableEvent);
    component!(path: erc721_owner_component, storage: erc721_owner, event: ERC721OwnerEvent);
    component!(path: erc721_metadata_component, storage: erc721_metadata, event: ERC721MetadataEvent);

    #[storage]
    struct Storage {
        #[substorage(v0)]
        initializable: initializable_component::Storage,
        #[substorage(v0)]
        erc721_approval: erc721_approval_component::Storage,
        #[substorage(v0)]
        erc721_balance: erc721_balance_component::Storage,
        #[substorage(v0)]
        erc721_burnable: erc721_burnable_component::Storage,
        #[substorage(v0)]
        erc721_enumerable: erc721_enumerable_component::Storage,
        #[substorage(v0)]
        erc721_mintable: erc721_mintable_component::Storage,
        #[substorage(v0)]
        erc721_owner: erc721_owner_component::Storage,
        #[substorage(v0)]
        erc721_metadata: erc721_metadata_component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        InitializableEvent: initializable_component::Event,
        ERC721ApprovalEvent: erc721_approval_component::Event,
        ERC721BalanceEvent: erc721_balance_component::Event,
        ERC721BurnableEvent: erc721_burnable_component::Event,
        ERC721EnumerableEvent: erc721_enumerable_component::Event,
        ERC721MintableEvent: erc721_mintable_component::Event,
        ERC721OwnerEvent: erc721_owner_component::Event,
        ERC721MetadataEvent: erc721_metadata_component::Event,
    }

    mod Errors {
        const CALLER_IS_NOT_OWNER: felt252 = 'ERC721: caller is not owner';
        const CALLER_IS_NOT_MINTER: felt252 = 'ERC721: caller is not minter';
        const MINTING_IS_CLOSED: felt252 = 'ERC721: minting closed';
        const INVALID_ACCOUNT: felt252 = 'ERC721: invalid account';
        const UNAUTHORIZED: felt252 = 'ERC721: unauthorized caller';
        const INVALID_RECEIVER: felt252 = 'ERC721: invalid receiver';
        const WRONG_SENDER: felt252 = 'ERC721: wrong sender';
        const SAFE_TRANSFER_FAILED: felt252 = 'ERC721: safe transfer failed';
    }

    impl InitializableImpl = initializable_component::InitializableImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721ApprovalImpl = erc721_approval_component::ERC721ApprovalImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721ApprovalCamelImpl = erc721_approval_component::ERC721ApprovalCamelImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721EnumerableImpl = erc721_enumerable_component::ERC721EnumerableImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721EnumerableCamelImpl = erc721_enumerable_component::ERC721EnumerableCamelImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataCamelImpl = erc721_metadata_component::ERC721MetadataCamelImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721OwnerImpl = erc721_owner_component::ERC721OwnerImpl<ContractState>;
    #[abi(embed_v0)]
    impl ERC721MetadataImpl = erc721_metadata_component::ERC721MetadataImpl<ContractState>;

    //
    // Internal Impls
    //
    
    impl InitializableInternalImpl = initializable_component::InternalImpl<ContractState>;
    impl ERC721ApprovalInternalImpl = erc721_approval_component::InternalImpl<ContractState>;
    impl ERC721BalanceInternalImpl = erc721_balance_component::InternalImpl<ContractState>;
    impl ERC721BurnableInternalImpl = erc721_burnable_component::InternalImpl<ContractState>;
    impl ERC721EnumerableInternalImpl = erc721_enumerable_component::InternalImpl<ContractState>;
    impl ERC721MintableInternalImpl = erc721_mintable_component::InternalImpl<ContractState>;
    impl ERC721OwnerInternalImpl = erc721_owner_component::InternalImpl<ContractState>;
    impl ERC721MetadataInternalImpl = erc721_metadata_component::InternalImpl<ContractState>;

    #[abi(embed_v0)]
    impl EnumInitImpl of super::IERC721EnumInit<ContractState> {
        fn initialize(
            ref world: IWorldDispatcher,
            name: ByteArray,
            symbol: ByteArray,
            base_uri: ByteArray,
        ) {
            self.erc721_metadata.initialize(name, symbol, base_uri);
            self.initializable.initialize();
        }
    }

    #[abi(embed_v0)]
    impl EnumTransferImpl of super::IERC721EnumTransfer<ContractState> {
        fn balance_of(world: @IWorldDispatcher, account: ContractAddress) -> u256 {
            self.erc721_balance.get_balance(account).amount.into()
        }

        fn transfer_from(ref world: IWorldDispatcher, from: ContractAddress, to: ContractAddress, token_id: u256) {
            assert(
                self.erc721_approval.is_approved_or_owner(get_caller_address(), token_id),
                Errors::UNAUTHORIZED
            );
            self.erc721_balance.transfer_internal(from, to, token_id);
            self.erc721_enumerable.remove_token_from_owner_enumeration(from, token_id);
            self.erc721_enumerable.add_token_to_owner_enumeration(to, token_id);
        }

        fn safe_transfer_from(
            ref world: IWorldDispatcher,
            from: ContractAddress,
            to: ContractAddress,
            token_id: u256,
            data: Span<felt252>
        ) {
            assert(
                self.erc721_approval.is_approved_or_owner(get_caller_address(), token_id),
                Errors::UNAUTHORIZED
            );
            self.erc721_balance.safe_transfer_internal(from, to, token_id, data);
            self.erc721_enumerable.remove_token_from_owner_enumeration(from, token_id);
            self.erc721_enumerable.add_token_to_owner_enumeration(to, token_id);
        }
    }

    #[abi(embed_v0)]
    impl EnumMintBurnImpl of super::IERC721EnumMintBurn<ContractState> {
        fn mint(
            ref world: IWorldDispatcher,
            to: ContractAddress,
            token_id: u256,
        ) {
// 'KARAT_MINT_to...'.print();
// to.print();
            let config: Config = ConfigManagerTrait::new(world).get(get_contract_address());
            assert(
                config.is_open,
                Errors::MINTING_IS_CLOSED,
            );
            assert(
                config.is_minter(get_caller_address()),
                Errors::CALLER_IS_NOT_MINTER
            );
            self.erc721_mintable.mint(to, token_id);
            self.erc721_enumerable.add_token_to_all_tokens_enumeration(token_id);
            self.erc721_enumerable.add_token_to_owner_enumeration(to, token_id);
        }
        fn burn(
            ref world: IWorldDispatcher,
            token_id: u256,
        ) {
            self.erc721_burnable.burn(token_id);
            self.erc721_enumerable.remove_token_from_all_tokens_enumeration(token_id);
            let owner = self.erc721_owner.owner_of(token_id);
            self.erc721_enumerable.remove_token_from_owner_enumeration(owner, token_id);
        }
    }
}
