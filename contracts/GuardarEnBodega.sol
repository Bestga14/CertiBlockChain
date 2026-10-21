//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {HumedadInterface} from "./oraculo_humedad/HumedadInterface.sol";

contract GuardarEnBodega {
    HumedadInterface public oraculo;
    uint256 public constant ANTIGUEDAD_MAX = 2 hours;
    int256 public constant HUMEDAD_MAX = 12;

    error DatoDesactualizado(uint256 tiempo);

    constructor(address _oraculo) {
        oraculo = HumedadInterface(_oraculo);
    }

     function listoParaGuardar() external view returns (bool) {
         (int256 humedad, uint256 actualizado) = oraculo.humedadActual();

        if (block.timestamp - actualizado > ANTIGUEDAD_MAX) {
            revert DatoDesactualizado(block.timestamp - actualizado);
        }
        if (humedad < HUMEDAD_MAX) return true;
        return false;
    }
}