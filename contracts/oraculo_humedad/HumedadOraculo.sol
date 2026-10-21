// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {HumedadInterface} from "./HumedadInterface.sol";

contract HumedadOraculo is HumedadInterface {
    address public admin;
    int256 private humedad;   
    uint256 private actualizado;  
    
    int256 public constant MINIMO = 0; 
    int256 public constant MAXIMO = 100; 

    event HumedadActualizada(int256 porcentajeHumedad, uint256 actualizado);
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
    }

    function actualizarHumedad(int256 porcentajeHumedad) external soloAdmin {
        if (porcentajeHumedad < MINIMO || porcentajeHumedad > MAXIMO) revert FueraDeRango(porcentajeHumedad);
        humedad = porcentajeHumedad;
        actualizado = block.timestamp;
        emit HumedadActualizada(porcentajeHumedad, block.timestamp);
    }

    function humedadActual() external view override returns (int256, uint256) {
        if (actualizado == 0) revert SinDatos();
        return (humedad, actualizado);
    }
}