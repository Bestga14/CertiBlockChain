// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

/// @title TrazabilidadCafe
/// @notice Registra el recorrido de un lote de café desde la cosecha hasta la distribución, incluyendo actores, etapas y documentos asociados.
contract TrazabilidadCafe {
    // ─── Tipos ──────────────────────────────────────────────
    enum Rol {
        Ninguno,
        Productor,
        Procesador,
        Transportista,
        Tostador,
        Distribuidor
    }

// Etapas de producción del café, cada una asociada a un rol específico
    enum Etapa {
        Cosechado,    // Registra el Productor al momento de cocehar el café
        Beneficiado,  // el Procesador (lavado, secado, trillado)
        Transportado, // el Transportista
        Tostado,      // el Tostador
        Distribuido   // el Distribuidor
    }

    struct Lote {
        uint256 id;             // IDentificador único del lote
        string origen;          // Lugar de origen del café (ej. finca, región) 
        address productor;      // Dirección de billetera del productor que creó el lote
        address custodio;       // Dirección de billetera del actor que actualmente tiene la custodia del lote
        Etapa etapa;            // Etapa actual del lote en la cadena de producción
        uint64 fechaCreacion;   // Fecha de creación del lote (timestamp)    
    }

    struct Registro {
        Etapa etapa;            // Etapa registrada
        address actor;          // Dirección de billetera del actor que registra la etapa
        uint64 fecha;           // Fecha de registro (timestamp)
        string detalle;         // Glosa o descripción de la etapa (ej. "Café lavado y secado")
    }

    address public admin;       // Dirección de billetera del administrador del contrato
    uint256 public totalLotes;  // Cantidad total de lotes registrados en el contrato

    mapping(address => Rol) public roles;               // Arreglo de todos los actores registrados y sus roles
    mapping(uint256 => Lote) private lotes;             // Arreglo de todos los lotes registrados, indexados por su ID
    mapping(uint256 => Registro[]) private historial;   // Arreglo de registros de cada lote, indexados por el ID del lote

    // Eventos 
    event ActorRegistrado(address indexed actor, Rol rol);
    event LoteCreado(uint256 indexed idLote, address indexed productor, string origen);
    event EtapaRegistrada(uint256 indexed idLote, Etapa etapa, address indexed actor);
    event CustodiaTransferida(uint256 indexed idLote, address indexed de, address indexed para);

    // Errores 
    error NoEsAdmin();
    error RolIncorrecto(Rol requerido, Rol actual);
    error NoEsCustodio(uint256 idLote);
    error LoteInexistente(uint256 idLote);
    error LoteFinalizado(uint256 idLote);
    error DireccionInvalida();

    // Modificadores
    modifier soloAdmin() {
        if (msg.sender != admin) revert NoEsAdmin();
        _;
    }

    modifier loteExiste(uint256 idLote) {
        if (idLote == 0 || idLote > totalLotes) revert LoteInexistente(idLote);
        _;
    }

    modifier soloCustodio(uint256 idLote) {
        if (lotes[idLote].custodio != msg.sender) revert NoEsCustodio(idLote);
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // Administración de actores
    function registrarActor(address actor, Rol rol) external soloAdmin {
        if (actor == address(0)) revert DireccionInvalida();
        roles[actor] = rol;
        emit ActorRegistrado(actor, rol);
    }

    // Productor: crear lote. En este diseño crea el productor y el mismo es el custodio inicial.
    function crearLote(string calldata origen, string calldata detalle) 
    external returns (uint256 idLote) {
        if (roles[msg.sender] != Rol.Productor) revert RolIncorrecto(Rol.Productor, roles[msg.sender]);

        idLote = ++totalLotes;
        lotes[idLote] = Lote({
            id: idLote,
            origen: origen,
            productor: msg.sender,
            custodio: msg.sender,
            etapa: Etapa.Cosechado,
            fechaCreacion: uint64(block.timestamp)
        });

        _registrar(idLote, Etapa.Cosechado, detalle);
        emit LoteCreado(idLote, msg.sender, origen);
    }

    // Custodio: pasar el lote al siguiente actor para que lo custodie
    function transferirCustodia(
        uint256 idLote,
        address nuevoCustodio
    ) external loteExiste(idLote) soloCustodio(idLote) {
        Lote storage lote = lotes[idLote];
        if (lote.etapa == Etapa.Distribuido) revert LoteFinalizado(idLote);

        // El receptor debe tener el rol de la siguiente etapa
        Rol requerido = rolParaEtapa(Etapa(uint8(lote.etapa) + 1));
        if (roles[nuevoCustodio] != requerido) revert RolIncorrecto(requerido, roles[nuevoCustodio]);

        emit CustodiaTransferida(idLote, msg.sender, nuevoCustodio);
        lote.custodio = nuevoCustodio;
    }

    // Custodio: registrar la siguiente etapa 
    function avanzarEtapa(uint256 idLote, string calldata detalle) external loteExiste(idLote) soloCustodio(idLote) {
        Lote storage lote = lotes[idLote];
        if (lote.etapa == Etapa.Distribuido) revert LoteFinalizado(idLote);

        Etapa siguiente = Etapa(uint8(lote.etapa) + 1);
        Rol requerido = rolParaEtapa(siguiente);
        if (roles[msg.sender] != requerido) revert RolIncorrecto(requerido, roles[msg.sender]);

        lote.etapa = siguiente;
        _registrar(idLote, siguiente, detalle);
    }

    // Obtener información de lotes y su historial 
    function obtenerLote(uint256 idLote) external view loteExiste(idLote) returns (Lote memory) {
        return lotes[idLote];
    }

    function obtenerHistorial(uint256 idLote) external view loteExiste(idLote) returns (Registro[] memory) {
        return historial[idLote];
    }

    function rolParaEtapa(Etapa etapa) public pure returns (Rol) {
        // Cosechado(0)→Productor(1), Beneficiado(1)→Procesador(2), ...
        return Rol(uint8(etapa) + 1);
    }

    //  Interno ────────────────────────────────────────────
    function _registrar(uint256 idLote, Etapa etapa, string calldata detalle) private {
        historial[idLote].push(
            Registro({
                etapa: etapa,
                actor: msg.sender,
                detalle: detalle,
                fecha: uint64(block.timestamp)
        
            })
        );
        emit EtapaRegistrada(idLote, etapa, msg.sender);
    }
}