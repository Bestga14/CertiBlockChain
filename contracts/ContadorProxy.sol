// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

/// El proxy: guarda el estado y delega toda llamada a la implementación actual.
/// Se declara aquí para que Hardhat lo compile y genere su artifact.
contract ContadorProxy is ERC1967Proxy {
    constructor(address implementacion, bytes memory datosInicializacion)
        ERC1967Proxy(implementacion, datosInicializacion)
    {}
}