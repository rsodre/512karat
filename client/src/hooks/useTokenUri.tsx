import { BigNumberish } from "starknet";
import { useDojo } from "../dojo/useDojo"
import { useTokenContract } from "./useToken";
import { useEffect, useMemo, useState } from "react";
import { decodeBase64 } from "../utils";

type MetadataType = {
  name: string
  description: string
  attributes: any
  image: string
}

export const useTokenUri = (token_id: BigNumberish) => {
  const {
    setup: {
      systemCalls: { token_uri },
    },
  } = useDojo();

  const { contractAddress } = useTokenContract();

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


  const metadata = useMemo<MetadataType>(() => {
    if (uri) {
      try {
        return JSON.parse(uri)
      } catch (e) {
        console.error(`METADATA ERROR:`, e, uri)
      }
    }
    return {}
  }, [uri])
  // console.log(`META:::`,metadata)

  const { name, description, attributes, image } = metadata

  // const svg = useMemo(() => decodeBase64(image), [image])
  // console.log(image, svg)

  return {
    // token_uri: _fetch
    token_id,
    uri,
    name,
    description,
    attributes,
    image,
  }
}

