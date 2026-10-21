// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface HumedadInterface {
    function humedadActual() external view returns (int256 humedad, uint256 actualizado);
}