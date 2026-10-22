// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {GobiernoInterface} from "./GobiernoInterface.sol";

contract OraculoGobierno is GobiernoInterface {
    address public admin;

    int256 public constant MINIMO = 0;

    struct Precip {
        int256 precip;
        bool existe;
    }

    mapping(uint256 => Precip) private precipitacionObj;

    event PrecipitacionRegistrada(int256 precipitacionHoy, uint256 fecha);
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

    function registrarPrecipitacion(int256 precipitacionHoy) external soloAdmin {
        if (precipitacionHoy < MINIMO) revert FueraDeRango(precipitacionHoy);

        precipitacionObj[block.timestamp] = Precip({
            precip: precipitacionHoy,
            existe: true
        });

        emit PrecipitacionRegistrada(precipitacionHoy, block.timestamp);
    }

    function precipitacionPorFecha(uint256 fecha) external view override returns (int256) {
        Precip memory p = precipitacionObj[fecha];
        if (!p.existe) revert SinDatos();
        
        return p.precip;
    }
}