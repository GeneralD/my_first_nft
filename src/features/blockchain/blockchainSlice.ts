
import Web3 from 'web3'

import { createAsyncThunk, createSlice } from '@reduxjs/toolkit'

import { connectBlockchain } from './blockchainAPI'

export const connectAsync = createAsyncThunk('blockchain/connect', connectBlockchain)

export interface BlockchainState {
    isLoading: boolean,
    web3?: Web3,
    account?: string,
    smartContract?: any,
    errorMessage?: string,
}

const initialState: BlockchainState = {
    isLoading: false,
}

export const blockchainSlice = createSlice({
    name: 'blockchain',
    initialState: initialState,
    reducers: {

    },
    extraReducers: builder => {
        builder
            .addCase(connectAsync.pending, state => {
                state.isLoading = true
                state.errorMessage = undefined
            })
            .addCase(connectAsync.fulfilled, (state, action) => {
                state.isLoading = false
                state.web3 = action.payload.web3
                state.account = action.payload.account
                state.smartContract = action.payload.smartContract
                state.errorMessage = undefined
            })
            .addCase(connectAsync.rejected, (state, action) => {
                state.isLoading = false
                state.errorMessage = action.error.message
            })
    }
})