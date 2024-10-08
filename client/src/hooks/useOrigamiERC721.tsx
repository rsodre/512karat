import { useMemo } from 'react'
import { BigNumberish } from 'starknet'
import { Components, getComponentValue } from '@dojoengine/recs'
import { useComponentValue } from '@dojoengine/react'
import { keysToEntity } from '../utils/types'


type MetadataResult = {
  name: string
  symbol: string
  baseUri: string
  isPending: boolean
}
export const useOrigamiERC721Metadata = (token: BigNumberish, components: Components): MetadataResult => {
  const { ERC721MetaModel } = components
  const result: any = useComponentValue(ERC721MetaModel, keysToEntity([token]))
  return {
    name: (result?.name ?? null),
    symbol: (result?.symbol ?? null),
    baseUri: (result?.base_uri ?? null),
    isPending: (result == null),
  }
}

type TotalSupplyResult = {
  totalSupply: number
  isPending: boolean
}
export const useOrigamiERC721TotalSupply = (token: BigNumberish, components: Components): TotalSupplyResult => {
  const { ERC721EnumerableTotalModel } = components
  const result: any = useComponentValue(ERC721EnumerableTotalModel, keysToEntity([token]))
  return {
    totalSupply: result ? Number(result.total_supply) : 0,
    isPending: (result == null),
  }
}

type OwnerOfResult = {
  owner: bigint
  isPending: boolean
}
export const useOrigamiERC721OwnerOf = (token: BigNumberish, token_id: BigNumberish, components: Components): OwnerOfResult => {
  const { ERC721OwnerModel } = components
  const result: any = useComponentValue(ERC721OwnerModel, keysToEntity([token, token_id]))
  return {
    owner: result ? BigInt(result.address) : 0n,
    isPending: (result == null),
  }
}

type BalanceOfResult = {
  amount: number
  isPending: boolean
}
export const useOrigamiERC721BalanceOf = (token: BigNumberish, account: BigNumberish, components: Components): BalanceOfResult => {
  const { ERC721BalanceModel } = components
  const result: any = useComponentValue(ERC721BalanceModel, keysToEntity([token, account]))
  return {
    amount: result ? Number(result.amount) : 0,
    isPending: (result == null),
  }
}

type TokenByIndexResult = {
  tokenId: bigint
  isPending: boolean
}
export const useOrigamiERC721TokenByIndex = (token: BigNumberish, index: BigNumberish, components: Components): TokenByIndexResult => {
  const { ERC721EnumerableIndexModel } = components
  const result: any = useComponentValue(ERC721EnumerableIndexModel, keysToEntity([token, index]))
  return {
    tokenId: result ? BigInt(result.token_id) : 0n,
    isPending: (result == null),
  }
}

type TokenOfOwnerByIndexResult = {
  tokenId: bigint
  isPending: boolean
}
export const useOrigamiERC721TokenOfOwnerByIndex = (token: BigNumberish, owner: BigNumberish, index: BigNumberish, components: Components): TokenOfOwnerByIndexResult => {
  const { ERC721EnumerableOwnerIndexModel } = components
  const result: any = useComponentValue(ERC721EnumerableOwnerIndexModel, keysToEntity([token, owner, index]))
  return {
    tokenId: result ? BigInt(result.token_id) : 0n,
    isPending: (result == null),
  }
}

type IndexByTokenResult = {
  index: number
  isPending: boolean
}
export const useOrigamiERC721IndexByToken = (token: BigNumberish, token_id: BigNumberish, components: Components): IndexByTokenResult => {
  const { ERC721EnumerableTokenModel } = components
  const result: any = useComponentValue(ERC721EnumerableTokenModel, keysToEntity([token, token_id]))
  return {
    index: result ? Number(result.index) : 0,
    isPending: (result == null),
  }
}

type IndexOfOwnerByTokenResult = {
  index: number
  isPending: boolean
}
export const useOrigamiERC721IndexOfOwnerByToken = (token: BigNumberish, owner: BigNumberish, token_id: BigNumberish, components: Components): IndexOfOwnerByTokenResult => {
  const { ERC721EnumerableOwnerTokenModel } = components
  const result: any = useComponentValue(ERC721EnumerableOwnerTokenModel, keysToEntity([token, owner, token_id]))
  return {
    index: result ? Number(result.index) : 0,
    isPending: (result == null),
  }
}

type useOrigamiERC721AllTokensOfOwnerResult = {
  tokenIds: bigint[]
  isPending: boolean
}
export const useOrigamiERC721AllTokensOfOwner = (token: BigNumberish, owner: BigNumberish, components: Components): useOrigamiERC721AllTokensOfOwnerResult => {
  const { ERC721EnumerableOwnerIndexModel } = components
  const { amount, isPending: isBalancePending } = useOrigamiERC721BalanceOf(token, owner, components)
  const tokenIds = useMemo(() => {
    return Array.from({ length: amount }, (_, i) => i).map((index) => {
      const result = getComponentValue(ERC721EnumerableOwnerIndexModel, keysToEntity([token, owner, index]))
      // console.log(`>>>> ALL:`, isBalancePending, index, result)
      return result ? BigInt(result.token_id) : 0n
    })
  }, [token, owner, amount, isBalancePending])
  return {
    tokenIds,
    isPending: isBalancePending,
  }
}
