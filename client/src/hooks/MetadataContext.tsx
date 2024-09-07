import React, { ReactNode, createContext, useReducer, useContext, useMemo, useEffect, useCallback } from 'react'
import { BigNumberish } from 'starknet'

//
// React + Typescript + Context
// https://react-typescript-cheatsheet.netlify.app/docs/basic/getting-started/context
//

//--------------------------------
// State
//

type UriMap = {
  [key: string]: string
}

export const initialState = {
  uri: {} as UriMap,
}

const MetadataActions = {
  SET_URI: 'SET_URI',
}


//--------------------------------
// Types
//
type MetadataContextStateType = typeof initialState

type ActionType =
  | { type: 'SET_URI', payload: { token_id: BigNumberish, uri: string } }



//--------------------------------
// Context
//
const MetadataContext = createContext<{
  state: MetadataContextStateType
  dispatch: React.Dispatch<any>
}>({
  state: initialState,
  dispatch: () => null,
})

//--------------------------------
// Provider
//
interface MetadataProviderProps {
  children: string | JSX.Element | JSX.Element[] | ReactNode
}
const MetadataProvider = ({
  children,
}: MetadataProviderProps) => {

  const [state, dispatch] = useReducer((state: MetadataContextStateType, action: ActionType) => {
    let newState = { ...state }
    switch (action.type) {
      case MetadataActions.SET_URI: {
        const { token_id, uri } = action.payload
        newState.uri[BigInt(token_id).toString()] = uri
        break
      }
      default:
        console.warn(`MetadataProvider: Unknown action [${action.type}]`)
        return state
    }
    return newState
  }, initialState)

  return (
    <MetadataContext.Provider value={{ dispatch, state: {
      ...state,
    } }}>
      {children}
    </MetadataContext.Provider>
  )
}

export { MetadataProvider, MetadataContext, MetadataActions }


//--------------------------------
// Hooks
//

export const useMetadataContext = () => {
  const { state, dispatch } = useContext(MetadataContext)
  const dispatchSetUri = (token_id: BigNumberish, uri: string) => {
    dispatch({
      type: MetadataActions.SET_URI,
      payload: { token_id, uri }
    })
  }
  return {
    ...state,
    dispatchSetUri,
  }
}

export const useTokenUriContext = (token_id: BigNumberish) => {
  const { state } = useContext(MetadataContext)
  return state.uri[BigInt(token_id).toString()] ?? undefined
}
