import { BigNumberish } from "starknet";
import { useDojo } from "../dojo/useDojo"
import { useTokenContract } from "./useToken";
import { useEffect, useState } from "react";

export const useTokenUri = (token_id: BigNumberish) => {
  const {
    setup: {
      systemCalls: { token_uri },
    },
  } = useDojo();

  const { contractAddress } = useTokenContract();
  // const canFetch = useMemo(() => (Boolean(token_id) && Boolean(contractAddress)), [token_id, contractAddress])

  const [uri, setUri] = useState('')
  const _fetch = () => {
    if (contractAddress && token_id) {
      token_uri(token_id).then((v) => {
        setUri(v ?? '')
      }).catch((e) => {
        console.error(`useTokenUri() ERROR:`, e)
      });
    } else {
      return null
    }
  }

  useEffect(() => {
    _fetch();
  }, [contractAddress, token_id])

  return {
    // token_uri: _fetch
    uri,
  }
}

