import React, { ReactNode, createContext, useReducer, useContext } from 'react'

//--------------------------------
// State
//

export const initialState = {
  gridSize: 9,
  pageIndex: 0,
  tokenId: 0,
  gridMode: true,
}

const StateContextActions = {
  SET_PAGE_INDEX: 'SET_PAGE_INDEX',
  SET_TOKEN_ID: 'SET_TOKEN_ID',
}


//--------------------------------
// Types
//
type StateContextStateType = typeof initialState

type ActionType =
  | { type: 'SET_PAGE_INDEX', payload: number }
  | { type: 'SET_TOKEN_ID', payload: number }


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
      case StateContextActions.SET_PAGE_INDEX: {
        newState.pageIndex = action.payload as number
        break
      }
      case StateContextActions.SET_TOKEN_ID: {
        newState.tokenId = action.payload as number
        newState.gridMode = !Boolean(newState.tokenId)
        break
      }
      default:
        console.warn(`StateProvider: Unknown action [${action.type}]`)
        return state
    }
    return newState
  }, initialState)

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

export const useStateContext = () => {
  const { state, dispatch } = useContext(StateContext)
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
  return {
    ...state,
    // StateContextActions,
    // dispatch,
    dispatchSetPageIndex,
    dispatchSetTokenId,
  }
}



