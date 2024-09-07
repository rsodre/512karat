
import { useCallback, useMemo } from 'react'
import { useAccount } from '@starknet-react/core'
import { SwitchStarknetChainParameter, AddStarknetChainParameters } from 'get-starknet-core'
import { defaultChainId } from '../dojo/dojoConfig'
import { feltToString } from '../utils/starknet'


export const useIsCorrectChain = () => {
  const { chainId } = useAccount();
  const currentChainId = useMemo(() => (
    chainId ? feltToString(chainId) : undefined
  ), [chainId])
  const isCorrectChain = useMemo(() => (
    currentChainId ? (currentChainId === defaultChainId) : undefined
  ), [currentChainId, defaultChainId])
  return {
    isCorrectChain,
    currentChainId,
  }
}

export const useSwitchStarknetChain = (params: SwitchStarknetChainParameter) => {
  const switch_starknet_chain = useCallback(() => {
    console.log(`useSwitchStarknetChain()...`, params)
    return window?.starknet?.request({ type: 'wallet_switchStarknetChain', params }) ?? Promise.resolve(false)
  }, [params])
  return {
    switch_starknet_chain,
  }
}

export const useChainSwitchCallback = () => {
  const { isCorrectChain } = useIsCorrectChain()

  const switch_params = useMemo(() => {
    const params: SwitchStarknetChainParameter = {
      chainId: defaultChainId,
    }
    return params
  }, [defaultChainId])
  const { switch_starknet_chain } = useSwitchStarknetChain(switch_params)

  return {
    switch_starknet_chain: (isCorrectChain === false ? switch_starknet_chain : undefined),
    switchMessage: (isCorrectChain === false ? `Switch to ${defaultChainId}` : undefined),
  }
}


