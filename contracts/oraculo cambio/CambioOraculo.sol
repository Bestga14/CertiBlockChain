// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {CambioInterface} from "./CambioInterface.sol";

contract CambioOraculo is CambioInterface {
    address public admin;
    int256 private monto;   // la temperatura en décimas de grado Celsius (por ejemplo, 215 = 21,5 °C)
    uint256 private actualizado;  // fecha y hora de la actualización en formato timestamp

    int256 public constant MINIMO = 0; // -90,0 °C
    //int256 public constant MAXIMO = 600;  //  60,0 °C

    event CambioActualizado(int256 monto, uint256 actualizado);
    event AdminCambiado(address anterior, address nuevo);

    error NoEsAdmin();
    error FueraDeRango(int256 valor);
    error SinDatos();

    modifier soloAdmin() {
        if (msg.sender != admin) revert NoEsAdmin();
        _;
    }

    constructor() {
        admin = msg.sender;
        monto = 12;
        actualizado = block.timestamp;
    }

    function actualizarCambio(int256 nuevoCambio) external soloAdmin {
        if (nuevoCambio <= MINIMO) revert FueraDeRango(nuevoCambio);
        monto = nuevoCambio;
        actualizado = block.timestamp;
        emit CambioActualizado(nuevoCambio, block.timestamp);
    }

    function cambioActual() external view override returns (int256, uint256) {
        if (actualizado == 0) revert SinDatos();
        return (monto, actualizado);
    }
}