// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract CartaPokemon {
    address public admin;
    uint256 public cantidadCartas;

    struct Carta {
        uint256 nroCarta;
        address duenio;
        uint256 nroPokedex;
        uint256 precio;
    }

    mapping(uint256 => Carta) public cartas;

    event agregarAdmin(address indexed admin);
    event agregarCarta(uint256 indexed nroCarta, address indexed duenio, uint256 nroPokedex, uint256 precio);

    error NoEsAdmin();
    error CartaInexistente(uint256 id);
    error DireccionInvalida();

// El contructor establece al creador del contrato como administrador inicial
    constructor() {
        admin = msg.sender;
    }

    modifier soloAdmin() {
        if (msg.sender != admin) revert NoEsAdmin();
        _;
    }
    
    function incrementarMazo(uint256 nroCarta, address duenio, uint256 nroPokedex, uint256 precio) external soloAdmin {
        if (duenio == address(0)) revert DireccionInvalida();
        cantidadCartas++;
        cartas[nroCarta] = Carta(nroCarta, duenio, nroPokedex, precio);
        emit agregarCarta(nroCarta, duenio, nroPokedex, precio);
    }

    function obtenerCarta( uint256 nroCarta ) external view returns (Carta memory) {
        Carta memory carta = cartas[nroCarta];
        if (carta.nroCarta == 0) revert CartaInexistente(nroCarta);
        return carta;
    }

}