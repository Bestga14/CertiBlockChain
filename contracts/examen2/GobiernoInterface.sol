// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface GobiernoInterface {
    function precipitacionPorFecha(uint256 fecha) external view returns (int256 precipitacion);
}