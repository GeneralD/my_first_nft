// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.9.0;

library ConvertLib {
    function convert(uint256 amount, uint256 conversionRate)
        public
        pure
        returns (uint256 convertedAmount)
    {
        return amount * conversionRate;
    }
}
