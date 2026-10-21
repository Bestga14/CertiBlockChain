// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Facturacion {
    address public admin;
    uint256 public cantidadFacturas;

    struct Factura {
        uint256 nroFactura;
        address cliente;
        uint256 monto;
        uint64 fecha;
    }

    mapping(uint256 => Factura) public facturas;

    event agregarAdmin(address indexed admin);
    event agregarFactura(uint256 indexed nroFactura, address indexed cliente, uint256 monto, uint64 fecha);

    error NoEsAdmin();
    error FacturaInexistente(uint256 id);
    error DireccionInvalida();

// El contructor establece al creador del contrato como administrador inicial
    constructor() {
        admin = msg.sender;
    }

    modifier soloAdmin() {
        if (msg.sender != admin) revert NoEsAdmin();
        _;
    }
    
    function facturar(uint256 nroFactura, address cliente, uint256 monto) external soloAdmin {
        if (cliente == address(0)) revert DireccionInvalida();
        cantidadFacturas++;
        facturas[nroFactura] = Factura(nroFactura, cliente, monto, uint64(block.timestamp));
        emit agregarFactura(nroFactura, cliente, monto, uint64(block.timestamp));
    }

    function obtenerFactura( uint256 nroFactura ) external view returns (Factura memory) {
        Factura memory factura = facturas[nroFactura];
        if (factura.nroFactura == 0) revert FacturaInexistente(nroFactura);
        return factura;
    }

}