import { Action, configureStore, ThunkAction } from '@reduxjs/toolkit'

import { blockchainSlice } from '../features/blockchain/blockchainSlice'
import { counterSlice } from '../features/counter/counterSlice'

export const store = configureStore({
  reducer: {
    counter: counterSlice.reducer,
    blockchain: blockchainSlice.reducer,
  },
})

export type AppDispatch = typeof store.dispatch
export type RootState = ReturnType<typeof store.getState>
export type AppThunk<ReturnType = void> = ThunkAction<
  ReturnType,
  RootState,
  unknown,
  Action<string>
>
