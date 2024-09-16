import { BigNumberish } from "starknet";
import { useDojo } from "../dojo/useDojo"
import { useTokenContract } from "./useToken";
import { useEffect, useMemo, useState } from "react";
import { useMetadataContext, useTokenUriContext } from "./MetadataContext";
import { decodeMetadata } from "../utils/decoder";

type MetadataType = {
  name: string
  description: string
  attributes: any
  image: string
}

type Attributes = {
  [key: string]: string,
}

export const useTokenUri = (token_id: BigNumberish) => {
  const {
    setup: {
      systemCalls: { token_uri },
    },
  } = useDojo();

  const { contractAddress } = useTokenContract();

  const { dispatchSetUri } = useMetadataContext()
  const cached_uri = useTokenUriContext(token_id)

  const [uri, setUri] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const _fetch = () => {
    if (contractAddress && token_id) {
      // console.log(`>>>> fetching token uri for ${token_id}`)
      setUri('')
      setIsLoading(true)
      token_uri(token_id).then((v) => {
        setUri(v ?? '')
        dispatchSetUri(token_id, v ?? '')
        setIsLoading(false)
      }).catch((e) => {
        console.error(`useTokenUri() ERROR:`, e)
        setIsLoading(false)
      });
    } else {
      return null
    }
  }

  useEffect(() => {
    if (cached_uri) {
      setUri(cached_uri)
    } else {
      _fetch();
    }
  }, [contractAddress, token_id, cached_uri])

  const metadata = useUriToMetadata(token_id, uri)

  return {
    // token_uri: _fetch
    ...metadata,
    isLoading,
  }
}


export const useUriToMetadata = (token_id: BigNumberish, uri: string) => {
  const metadata = useMemo<MetadataType>(() => {
    if (uri) {
      try {
        const { json, image } = decodeMetadata(uri)
        // console.log(`METADATA:::`, json, image)
        return {
          ...json,
          image, // original encoded data
        } as unknown as MetadataType
      } catch (e) {
        console.error(`METADATA ERROR:`, e, uri)
      }
    }
    return {} as MetadataType
  }, [uri])
  // console.log(`META:::`,metadata)

  const { name, description, image, attributes: rawAttributes } = metadata

  const attributes = useMemo(() => rawAttributes?.reduce((acc: Attributes, attr: any) => {
    acc[attr.trait] = attr.value
    return acc
  }, {} as Attributes), [rawAttributes])

  // const svg = useMemo(() => decodeBase64(image), [image])
  // console.log(image, svg)

  return {
    // token_uri: _fetch
    tokenExists: Boolean(name),
    token_id,
    uri,
    name: name ?? `Karat #${token_id}`,
    description,
    attributes,
    image,
  }
}
