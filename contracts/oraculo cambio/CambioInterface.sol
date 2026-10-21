// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

interface CambioInterface {
    function cambioActual() external view returns (int256 monto, uint256 actualizado);
}