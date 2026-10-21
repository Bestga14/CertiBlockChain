// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract LibroV1 is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    address public admin;
    uint256 public cantidadLibros;

    struct Libro {
        uint256 nroLibro;
        address cliente;
        uint64 fechaVenta;
    }

    mapping(uint256 => Libro) public libros;

    event agregarAdmin(address indexed admin);
    event agregarLibro(uint256 indexed nroLibro, address indexed cliente, uint64 fechaVenta);

    error NoEsAdmin();
    error LibroInexistente(uint256 id);
    error DireccionInvalida();

// El contructor establece al creador del contrato como administrador inicial
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers(); // nadie puede inicializar la implementación directamente
    }

    /// Reemplaza al constructor: se ejecuta una sola vez, a través del proxy
    function initialize(address owner) public initializer {
        __Ownable_init(owner);
    }

    modifier soloAdmin() {
        if (msg.sender != admin) revert NoEsAdmin();
        _;
    }
    
    function venderLibro(uint256 nroLibro, address cliente) external soloAdmin {
        if (cliente == address(0)) revert DireccionInvalida();
        cantidadLibros++;
        libros[nroLibro] = Libro(nroLibro, cliente, uint64(block.timestamp));
        emit agregarLibro(nroLibro, cliente, uint64(block.timestamp));
    }

    function obtenerLibro( uint256 nroLibro ) external view returns (Libro memory) {
        Libro memory libro = libros[nroLibro];
        if (libro.nroLibro == 0) revert LibroInexistente(nroLibro);
        return libro;
    }

    function version() external pure returns (string memory) {
        return "Gael";
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

}