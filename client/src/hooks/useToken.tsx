import { getContractByName } from "@dojoengine/core"
import { useEffect, useState } from "react"
import manifest from '../dojo/generated/manifest.json'

export const useTokenContract = () => {
  const [contractAddress, setContractAddress] = useState<string>()

  useEffect(() => {
    const contract = getContractByName(manifest, 'karat_token');
    setContractAddress(contract?.address)
  },[])

  return {
    contractAddress
  }
}