// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {TemperaturaInterface} from "./TemperaturaInterface.sol";

contract TemperaturaOraculo is TemperaturaInterface {
    address public admin;
    int256 private temperatura;   // la temperatura en décimas de grado Celsius (por ejemplo, 215 = 21,5 °C)
    uint256 private actualizado;  // fecha y hora de la actualización en formato timestamp

    int256 public constant MINIMO = -900; // -90,0 °C
    int256 public constant MAXIMO = 600;  //  60,0 °C

    event TemperaturaActualizada(int256 decimasGrado, uint256 actualizado);
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
        temperatura = 200;
        actualizado = block.timestamp;
    }

    function actualizarTemperatura(int256 decimasGrado) external soloAdmin {
        if (decimasGrado < MINIMO || decimasGrado > MAXIMO) revert FueraDeRango(decimasGrado);
        temperatura = decimasGrado;
        actualizado = block.timestamp;
        emit TemperaturaActualizada(decimasGrado, block.timestamp);
    }

    function temperaturaActual() external view override returns (int256, uint256) {
        if (actualizado == 0) revert SinDatos();
        return (temperatura, actualizado);
    }
}