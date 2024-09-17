import { useEffect, useMemo, useState } from "react"
import { getContractByName } from "@dojoengine/core"
import { useComponentValue } from "@dojoengine/react"
import { useDojo } from "../dojo/useDojo"
import { bigintToEntity } from "../utils/types"
import { BigNumberish } from "starknet"
import { useOrigamiERC721AllTokensOfOwner, useOrigamiERC721BalanceOf, useOrigamiERC721OwnerOf, useOrigamiERC721TokenOfOwnerByIndex, useOrigamiERC721TotalSupply } from "./useOrigamiERC721"

export const useTokenContract = () => {
  const { setup: { clientComponents } } = useDojo();
  const [contractAddress, setContractAddress] = useState<string>('')

  const { setup: { manifest } } = useDojo()
  useEffect(() => {
    const contract = getContractByName(manifest, 'karat', 'karat_token');
    setContractAddress(contract?.address ?? '')
  }, [])

  const contractEntityId = useMemo(() => bigintToEntity(contractAddress), [contractAddress])

  return {
    contractAddress,
    contractEntityId,
    components: clientComponents,
  }
}

type useConfigResult = {
  minterAddress: bigint
  rendererAddress: bigint
  maxSupply: number
  availableSupply: number
  isCoolDown: boolean
  isPending: boolean
}
export const useConfig = (): useConfigResult => {
  const { setup: { clientComponents: { Config } } } = useDojo();
  const { contractEntityId } = useTokenContract()
  const data: any = useComponentValue(Config, contractEntityId);
  return {
    minterAddress: BigInt(data?.minter_address ?? 0),
    rendererAddress: BigInt(data?.renderer_address ?? 0),
    maxSupply: Number(data?.max_supply ?? 0),
    availableSupply: Number(data?.available_supply ?? 0),
    isCoolDown: Boolean(data?.cool_down ?? false),
    isPending: (data == null),
  }
}

type useTotalSupplyResult = {
  totalSupply: number
  allTokenIds: number[]
  isPending: boolean
}
export const useTotalSupply = (): useTotalSupplyResult => {
  const { contractAddress, components } = useTokenContract()
  const { totalSupply, isPending } = useOrigamiERC721TotalSupply(contractAddress, components)
  const allTokenIds = useMemo(() => {
    return Array.from({ length: totalSupply ?? 0 }, (_, i) => i + 1)
  }, [totalSupply])

  return {
    totalSupply: totalSupply ?? 0,
    allTokenIds,
    isPending,
  }
}

type useTokenOwnerResult = {
  ownerAddress: bigint | null
  isPending: boolean
}
export const useTokenOwner = (token_id: BigNumberish): useTokenOwnerResult => {
  const { contractAddress, components } = useTokenContract()
  const { owner, isPending } = useOrigamiERC721OwnerOf(contractAddress, token_id, components)
  return {
    ownerAddress: owner,
    isPending,
  }
}

type useOwnerBalanceResult = {
  balance: number
  isPending: boolean
}
export const useOwnerBalance = (account: BigNumberish): useOwnerBalanceResult => {
  const { contractAddress, components } = useTokenContract()
  const { amount, isPending } = useOrigamiERC721BalanceOf(contractAddress, account, components)
  return {
    balance: amount ?? 0,
    isPending,
  }
}

type useTokenOfOwnerByIndexResult = {
  tokenId: bigint
  isPending: boolean
}
export const useTokenOfOwnerByIndex = (address: BigNumberish, index: BigNumberish): useTokenOfOwnerByIndexResult => {
  const { contractAddress, components } = useTokenContract()
  const { tokenId, isPending } = useOrigamiERC721TokenOfOwnerByIndex(contractAddress, address, index, components)
  return {
    tokenId,
    isPending,
  }
}

type useAllTokensOfOwnerResult = {
  tokenIdsOfOwner: number[]
  isPending: boolean
}
export const useAllTokensOfOwner = (address: BigNumberish): useAllTokensOfOwnerResult => {
  const { contractAddress, components } = useTokenContract()
  const { tokenIds, isPending } = useOrigamiERC721AllTokensOfOwner(contractAddress, address, components)
  const tokenIdsOfOwner = useMemo(() => {
    return tokenIds?.map((id) => Number(id)) ?? []
  }, [tokenIds])
  return {
    tokenIdsOfOwner,
    isPending,
  }
}

