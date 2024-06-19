import { getContractByName } from "@dojoengine/core"
import { useEffect, useMemo, useState } from "react"
import manifest from '../dojo/generated/manifest.json'
import { useDojo } from "../dojo/useDojo"
import { useComponentValue } from "@dojoengine/react"
import { getEntityIdFromKeys } from "@dojoengine/utils"
import { Entity } from "@dojoengine/recs"

export const useTokenContract = () => {
  const [contractAddress, setContractAddress] = useState<string>('')

  useEffect(() => {
    const contract = getContractByName(manifest, 'karat_token');
    setContractAddress(contract?.address ?? '')
  },[])

  const entityId = useMemo(() => (getEntityIdFromKeys([BigInt(contractAddress || 0)]) as Entity), [contractAddress])

  return {
    contractAddress,
    entityId,
  }
}

export const useTotalSupply = () => {
  const { setup: { clientComponents: { ERC721EnumerableTotalModel } } } = useDojo();
  const { entityId } = useTokenContract()
  const data = useComponentValue(ERC721EnumerableTotalModel, entityId);
  return {
    total_supply: Number(data?.total_supply ?? 0)
  }
}
