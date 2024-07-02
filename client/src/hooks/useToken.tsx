import { useEffect, useMemo, useState } from "react"
import { getContractByName } from "@dojoengine/core"
import { useComponentValue } from "@dojoengine/react"
import { useDojo } from "../dojo/useDojo"
import { bigintToEntity, keysToEntity } from "../utils/types"
import { BigNumberish } from "starknet"

export const useTokenContract = () => {
  const [contractAddress, setContractAddress] = useState<string>('')
  
  const { setup: { manifest } } = useDojo()
  useEffect(() => {
    const contract = getContractByName(manifest, 'karat_token');
    setContractAddress(contract?.address ?? '')
  },[])

  const contractEntityId = useMemo(() => bigintToEntity(contractAddress), [contractAddress])

  return {
    contractAddress,
    contractEntityId,
  }
}

export const useConfig = () => {
  const { setup: { clientComponents: { Config } } } = useDojo();
  const { contractEntityId } = useTokenContract()
  const data = useComponentValue(Config, contractEntityId);
  return {
    minterAddress: BigInt(data?.minter_address ?? 0),
    painterAddress: BigInt(data?.painter_address ?? 0),
    maxSupply: Number(data?.max_supply ?? 0),
    isCoolDown: Boolean(data?.cool_down ?? false),
    isClosed: !Boolean(data?.is_open ?? false),
  }
}

export const useTotalSupply = () => {
  const { setup: { clientComponents: { ERC721EnumerableTotalModel } } } = useDojo();
  const { contractEntityId } = useTokenContract()
  const data = useComponentValue(ERC721EnumerableTotalModel, contractEntityId);
  return {
    total_supply: Number(data?.total_supply ?? 0)
  }
}

export const useTokenOwner = (token_id: BigNumberish) => {
  const { setup: { clientComponents: { ERC721OwnerModel } } } = useDojo();
  const { contractAddress } = useTokenContract()
  const entityId = useMemo(() => keysToEntity([contractAddress, BigInt(token_id ?? 0) > 0 ? token_id : 0]), [contractAddress, token_id])
  const data = useComponentValue(ERC721OwnerModel, entityId);
  return {
    ownerAddress: data?.address ? BigInt(data?.address) : null
  }
}
