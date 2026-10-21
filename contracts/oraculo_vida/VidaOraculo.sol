// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {VidaInterface} from "./VidaInterface.sol";

contract VidaOraculo is VidaInterface {
    address public admin;

    struct Persona {
        bool vivo;   
        uint256 actualizado;
    }

    mapping(address => Persona) private personas;

    event PersonaAgregada(address indexed walletPersona);
    event estadoActualizado(bool vivo, uint256 actualizado);
    event AdminCambiado(address anterior, address nuevo);

    error NoEsAdmin();
    error SinDatos();
    error DireccionInvalida();
    error NoSePuedeRevivir();
    error PersonaNoExiste();

    // ─── Constructor ────────────────────────────────────────
    constructor() {
        admin = msg.sender;
    }

    modifier soloAdmin() {
        if (msg.sender != admin) revert NoEsAdmin();
        _;
    }

    // ─── Administración ─────────────────────────────────────
    function agregarPersona(address walletPersona) external soloAdmin {
        if (walletPersona == address(0)) revert DireccionInvalida();
        personas[walletPersona] = Persona({
            vivo: true,
            actualizado: uint256(block.timestamp)
        });
        emit PersonaAgregada(walletPersona);
    }

    function actualizarEstado(address walletPersona, bool estado) external soloAdmin {
        if (walletPersona == address(0)) revert DireccionInvalida();
        Persona storage per = personas[walletPersona];
        if (estado == true && per.vivo == false) {
            revert NoSePuedeRevivir();
        } 

        if (estado == true && per.vivo == true) {
            per.actualizado = uint256(block.timestamp);
        } else {
            per.vivo = estado;
            per.actualizado = uint256(block.timestamp);
        }

        emit estadoActualizado(per.vivo, per.actualizado);
    }

    function estaVivo(address walletPersona) external view override returns (bool, uint256) {
        if (walletPersona == address(0)) revert DireccionInvalida();
        Persona memory per = personas[walletPersona];
        if (per.actualizado == 0) revert PersonaNoExiste();
        
        return (per.vivo, per.actualizado);
    }
}