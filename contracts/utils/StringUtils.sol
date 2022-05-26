// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

library StringUtils {
    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) internal pure returns (string memory) {
        bytes memory chars = bytes(str);
        bytes memory trimmed = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            trimmed[i - startIndex] = chars[i];
        }
        return string(trimmed);
    }

    function toInt(string memory str) public pure returns (uint256) {
        uint256 val = 0;
        bytes memory chars = bytes(str);
        for (uint256 i = 0; i < chars.length; i++) {
            uint256 exp = chars.length - i;
            uint256 jval = uint8(chars[i]) - uint256(0x30);
            val += (uint256(jval) * (10**(exp - 1)));
        }
        return val;
    }
}
