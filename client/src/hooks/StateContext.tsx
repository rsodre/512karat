import { useAccount } from '@starknet-react/core'
import React, { ReactNode, createContext, useReducer, useContext, useEffect, useMemo } from 'react'
import { useAllTokensOfOwner, useTotalSupply } from './useToken'

//--------------------------------
// State
//

export enum TokenSet {
  All = 'All',
  Collected = 'Collected',
  Info = 'Info',
}

export const initialState = {
  gridSize: 9,
  tokenSet: TokenSet.Info,
  pageIndex: 0,
  tokenId: 0,
  gridMode: true,
  allTokenIds: [] as number[],
  tokenIdsOfOwner: [] as number[],
}

enum StateContextActions {
  SET_TOKEN_SET = 'SET_TOKEN_SET',
  SET_PAGE_INDEX = 'SET_PAGE_INDEX',
  SET_TOKEN_ID = 'SET_TOKEN_ID',
  SET_ALL_TOKEN_IDS = 'SET_ALL_TOKEN_IDS',
  SET_TOKEN_IDS_OF_OWNER = 'SET_TOKEN_IDS_OF_OWNER',
}


//--------------------------------
// Types
//
type StateContextStateType = typeof initialState

type ActionType =
  | { type: 'SET_TOKEN_SET', payload: TokenSet }
  | { type: 'SET_PAGE_INDEX', payload: number }
  | { type: 'SET_TOKEN_ID', payload: number }
  | { type: 'SET_ALL_TOKEN_IDS', payload: number[] }
  | { type: 'SET_TOKEN_IDS_OF_OWNER', payload: number[] }


//--------------------------------
// Context
//
const StateContext = createContext<{
  state: StateContextStateType
  dispatch: React.Dispatch<any>
}>({
  state: initialState,
  dispatch: () => null,
})

//--------------------------------
// Provider
//
interface StateProviderProps {
  children: string | JSX.Element | JSX.Element[] | ReactNode
}
const StateProvider = ({
  children,
}: StateProviderProps) => {
  const [state, dispatch] = useReducer((state: StateContextStateType, action: ActionType) => {
    let newState = { ...state }
    switch (action.type) {
      case StateContextActions.SET_TOKEN_SET: {
        newState.tokenSet = action.payload as TokenSet
        newState.gridMode = true
        let tokens = _tokenSetIds(newState)
        const tokenIndex = state.tokenId ? tokens.indexOf(state.tokenId) : 0
        newState.pageIndex = (tokenIndex >= 0 ? Math.floor(tokenIndex / state.gridSize) : 0);
        break
      }
      case StateContextActions.SET_PAGE_INDEX: {
        newState.pageIndex = action.payload as number
        break
      }
      case StateContextActions.SET_TOKEN_ID: {
        newState.tokenId = action.payload as number
        newState.gridMode = !Boolean(newState.tokenId)
        break
      }
      case StateContextActions.SET_ALL_TOKEN_IDS: {
        newState.allTokenIds = [...action.payload as number[]]
        break
      }
      case StateContextActions.SET_TOKEN_IDS_OF_OWNER: {
        newState.tokenIdsOfOwner = [...action.payload as number[]]
        break
      }
      default:
        console.warn(`StateProvider: Unknown action [${action.type}]`)
        return state
    }
    return newState
  }, initialState)

  const { address } = useAccount();
  const { tokenIdsOfOwner } = useAllTokensOfOwner(address ?? 0n)
  const { allTokenIds } = useTotalSupply();

  useEffect(() => {
    dispatch({
      type: StateContextActions.SET_ALL_TOKEN_IDS,
      payload: allTokenIds,
    })
  }, [allTokenIds])

  useEffect(() => {
    dispatch({
      type: StateContextActions.SET_TOKEN_IDS_OF_OWNER,
      payload: tokenIdsOfOwner,
    })
  }, [tokenIdsOfOwner])

  return (
    <StateContext.Provider value={{ dispatch, state: {
      ...state,
    } }}>
      {children}
    </StateContext.Provider>
  )
}

export { StateProvider, StateContext, StateContextActions as StateActions }


//--------------------------------
// Hooks
//

const _tokenSetIds = (state: StateContextStateType) => (state.tokenSet === TokenSet.Collected ? state.tokenIdsOfOwner : state.allTokenIds)

export const useStateContext = () => {
  const { state, dispatch } = useContext(StateContext)
  const dispatchSetTokenSet = (newTokenSet: TokenSet) => {
    dispatch({
      type: StateContextActions.SET_TOKEN_SET,
      payload: newTokenSet,
    })
  }
  const dispatchSetPageIndex = (newPageIndex: number) => {
    dispatch({
      type: StateContextActions.SET_PAGE_INDEX,
      payload: newPageIndex,
    })
  }
  const dispatchSetTokenId = (newTokenId: number) => {
    dispatch({
      type: StateContextActions.SET_TOKEN_ID,
      payload: newTokenId,
    })
  }
  const tokenSetIds = useMemo(() => _tokenSetIds(state), [state])
  return {
    ...state,
    tokenSetIds,
    // StateContextActions,
    // dispatch,
    dispatchSetTokenSet,
    dispatchSetPageIndex,
    dispatchSetTokenId,
  }
}



