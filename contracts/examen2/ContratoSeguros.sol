// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

//import {SegurosInterface} from "./SegurosInterface.sol";
import {GobiernoInterface} from "./GobiernoInterface.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ContratoSeguros is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    GobiernoInterface public immutable oraculo;
    address public immutable admin;

    uint256 public constant DIAS_POLIZA = 90 days;  
    int256 public constant PRECIP_MIN = 50;

    struct Poliza{
        uint256 fechaInicioPoliza;
        int256 precipitacionAcumulada;
        bool indemnizacionDada;
    }

    mapping(address => Poliza) private polizas;

    event PolizaAgregada(address indexed walletAgricultor);
    event precActualizado(bool vivo, uint256 actualizado);

    error PrecioInvalido();
    error PrecioDesactualizado(uint256 actualizadoHace);
    error PagoInsuficiente(uint256 requerido, uint256 enviado);
    error NoEsAdmin();
    error TransferenciaFallida();

    // ─── Constructor ────────────────────────────────────────
    constructor(address direccionOraculo) {
        oraculo = GobiernoInterface(direccionOraculo);
        admin = msg.sender;
    }

    modifier soloAdmin() {
        if (msg.sender != admin) revert NoEsAdmin();
        _;
    }

    // ─── Administración ─────────────────────────────────────
    function agregarPoliza(address walletAgricultor) external soloAdmin {
        if (walletAgricultor == address(0)) revert DireccionInvalida();
        polizas[walletAgricultor] = Poliza({
            fechaInicioPoliza: block.timestamp,
            precipitacionAcumulada: 0,
            indemnizacionDada: false
        });
        emit PolizaAgregada(walletAgricultor);
    }

    function actualizarPrecipitacion(address wallet, int256 precip) external soloAdmin {
        if (wallet == address(0)) revert DireccionInvalida();
        Poliza storage pol = polizas[wallet];
        precipitacionAcumulada = pol.precipitacionAcumulada + oraculo.precipitacionPorFecha(block.timestamp);
        emit precActualizado(pol.precipitacionAcumulada);
    }

    function consultarIndem(address wallet) external view returns (string memory) {
        if (wallet == address(0)) revert DireccionInvalida();
        Poliza memory pol = polizas[wallet];
        if (pol.indemnizacionDada) return "La Indemnizacion ya fue Acreditada";
        if (block.timestamp - pol.fechaInicioPoliza < DIAS_POLIZA) return "Dias no cumplidos";
        if (pol.precipitacionAcumulada > PRECIP_MIN) return "Precipitacion no cumplida";

        return "Indemnizacion acreditada!";
    }

    function version() external pure returns (string memory) {
        return "V1";
    }

    /// Solo el owner puede cambiar la implementación
    function _authorizeUpgrade(address) internal override onlyOwner {}
}