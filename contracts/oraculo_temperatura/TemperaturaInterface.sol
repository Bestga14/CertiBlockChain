// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface TemperaturaInterface {
    function temperaturaActual() external view returns (int256 decimasGrado, uint256 actualizado);
}