// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {TemperaturaInterface} from "./oraculo_temperatura/TemperaturaInterface.sol";
import {HumedadInterface} from "./oraculo_humedad/HumedadInterface.sol";
import {AggregatorV3Interface} from "./oraculo cambio/AggregatorV3Interface.sol";

contract TiendaHelado {
    TemperaturaInterface public immutable oraculoTemp;
    HumedadInterface public immutable oraculoHumedad;
    AggregatorV3Interface public immutable oraculoEthUsd;

    address public immutable admin;

    uint256 public constant PRECIO_HELADO_USD = 2;  
    uint256 public constant PRECIO_DESCUENTO = 1;
    uint256 public constant ANTIGUEDAD_MAXIMA = 1 hours;
    int256 public constant TEMPERATURA_DESCUENTO = 150; // Si es menor = descuento
    int256 public constant HUMEDAD_DESCUENTO = 50; // Si es mayor = descuento

    mapping(address => uint256) public heladosComprados;

    event Compra(address indexed comprador, uint256 helados, uint256 pagadoWei, int256 precioEthUsd);

    error PrecioInvalido();
    error PrecioDesactualizado(uint256 actualizadoHace);
    error TempDesactualizado(uint256 actualizadoHace);
    error HumDesactualizado(uint256 actualizadoHace);
    error PagoInsuficiente(uint256 requerido, uint256 enviado);
    error NoEsAdmin();
    error TransferenciaFallida();

    constructor(address direccionOraculoTemp, address direccionOraculoHumedad, address direccionOraculoEthUsd) {
        oraculoTemp = TemperaturaInterface(direccionOraculoTemp);
        oraculoHumedad = HumedadInterface(direccionOraculoHumedad);
        oraculoEthUsd = AggregatorV3Interface(direccionOraculoEthUsd);
        admin = msg.sender;
    }

    function precioEthUsd() public view returns (int256) {
        (, int256 precio,, uint256 actualizado,) = oraculoEthUsd.latestRoundData();
        if (precio <= 0) revert PrecioInvalido();
        if (block.timestamp - actualizado > ANTIGUEDAD_MAXIMA) {
            revert PrecioDesactualizado(block.timestamp - actualizado);
        }
        return precio;
    }

    function costoHeladoEnWei() public view returns (uint256) {
        (int256 decimasGrado, uint256 actualizadoTemp) = oraculoTemp.temperaturaActual();
        (int256 humedad, uint256 actualizadoHum) = oraculoHumedad.humedadActual();

        if (block.timestamp - actualizadoTemp > ANTIGUEDAD_MAXIMA) {
            revert TempDesactualizado(block.timestamp - actualizadoTemp);
        }

        if (block.timestamp - actualizadoHum > ANTIGUEDAD_MAXIMA) {
            revert HumDesactualizado(block.timestamp - actualizadoHum);
        }

        if (decimasGrado < TEMPERATURA_DESCUENTO || humedad > HUMEDAD_DESCUENTO) {
            return (PRECIO_DESCUENTO * 1e8) / uint256(precioEthUsd());
        }
        return (PRECIO_HELADO_USD * 1e8) / uint256(precioEthUsd());
    }

    function comprar(uint256 cantidad) external payable {
        uint256 costo = costoHeladoEnWei() * cantidad;
        if (msg.value < costo) revert PagoInsuficiente(costo, msg.value);

        heladosComprados[msg.sender] += cantidad;
        emit Compra(msg.sender, cantidad, costo, precioEthUsd());

        uint256 vuelto = msg.value - costo;
        if (vuelto > 0) {
            (bool ok,) = msg.sender.call{value: vuelto}("");
            if (!ok) revert TransferenciaFallida();
        }
    }

    function retirar() external {
        if (msg.sender != admin) revert NoEsAdmin();
        (bool ok,) = admin.call{value: address(this).balance}("");
        if (!ok) revert TransferenciaFallida();
    }
}