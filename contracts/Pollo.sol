// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


contract Pollo {

    // ─── Roles ───────────────────────────────────────────

    enum Rol {
        Ninguno,
        Granjero,
        Procesador,
        Almacenista,
        Transportista,
        Receptor
    }

    // ─── Etapas ──────────────────────────────────────────

    enum Etapa {
        GranjaYCrianza,
        Procesamiento,
        Almacenamiento,
        Transporte,
        Recepcion
    }

    // ─── Lote principal ──────────────────────────────────

    struct Lote {
        uint256 id;
        string granja;
        address productor;
        address custodio;
        Etapa etapa;
        uint64 fechaCreacion;
    }

    // ─── Datos específicos de cada etapa ────────────────

    struct DatosGranja {
        string granja;
        string responsable;
        uint64 fechaInicio;
        uint256 cantidadPollos;
    }

    struct DatosProcesamiento {
        string plantaProcesadora;
        string responsable;
        uint64 fecha;
        uint256 pesoGramos;
        string controlSanitario;
    }

    struct DatosAlmacenamiento {
        string almacen;
        uint64 fechaIngreso;
        string responsable;
        int256 temperaturaDecimasC;
    }

    struct DatosTransporte {
        string transportista;
        string origen;
        string destino;
        uint64 fechaSalida;
        uint64 fechaLlegada;
        int256 temperaturaDecimasC;
    }

    struct DatosRecepcion {
        string establecimiento;
        string responsable;
        uint64 fechaRecepcion;
        uint256 cantidadRecibida;
        string observaciones;
    }

    // ─── Historial ───────────────────────────────────────

    struct Registro {
        Etapa etapa;
        address actor;
        uint64 fecha;
        string detalle;
    }

    // ─── Variables ───────────────────────────────────────

    address public admin;
    uint256 public totalLotes;

    mapping(address => Rol) public roles;
    mapping(uint256 => Lote) private lotes;
    mapping(uint256 => Registro[]) private historial;

    // Información de cada etapa por ID de lote
    mapping(uint256 => DatosGranja) public datosGranja;
    mapping(uint256 => DatosProcesamiento) public datosProcesamiento;
    mapping(uint256 => DatosAlmacenamiento) public datosAlmacenamiento;
    mapping(uint256 => DatosTransporte) public datosTransporte;
    mapping(uint256 => DatosRecepcion) public datosRecepcion;

    // ─── Eventos ─────────────────────────────────────────

    event ActorRegistrado(address indexed actor, Rol rol);

    event LoteCreado(
        uint256 indexed idLote,
        address indexed productor,
        string granja
    );

    event EtapaRegistrada(
        uint256 indexed idLote,
        Etapa etapa,
        address indexed actor
    );

    event CustodiaTransferida(
        uint256 indexed idLote,
        address indexed de,
        address indexed para
    );

    // ─── Errores ─────────────────────────────────────────

    error NoEsAdmin();
    error RolIncorrecto(Rol requerido, Rol actual);
    error NoEsCustodio(uint256 idLote);
    error LoteInexistente(uint256 idLote);
    error LoteFinalizado(uint256 idLote);
    error DireccionInvalida();
    error EtapaIncorrecta(Etapa esperada, Etapa actual);
    error DatoInvalido();
    error FechaInvalida();

    // ─── Modificadores ───────────────────────────────────

    modifier soloAdmin() {
        if (msg.sender != admin) revert NoEsAdmin();
        _;
    }

    modifier loteExiste(uint256 idLote) {
        if (idLote == 0 || idLote > totalLotes) {
            revert LoteInexistente(idLote);
        }
        _;
    }

    modifier soloCustodio(uint256 idLote) {
        if (lotes[idLote].custodio != msg.sender) {
            revert NoEsCustodio(idLote);
        }
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    // ─── Administración de actores ──────────────────────

    function registrarActor(
        address actor,
        Rol rol
    ) external soloAdmin {
        if (actor == address(0)) revert DireccionInvalida();

        roles[actor] = rol;

        emit ActorRegistrado(actor, rol);
    }

    // ─── ETAPA 1: GRANJA Y CRIANZA ───────────────────────

    function crearLote(
        string calldata granja,
        string calldata responsable,
        uint64 fechaInicio,
        uint256 cantidadPollos
    ) external returns (uint256 idLote) {

        if (roles[msg.sender] != Rol.Granjero) {
            revert RolIncorrecto(
                Rol.Granjero,
                roles[msg.sender]
            );
        }

        if (cantidadPollos == 0) revert DatoInvalido();
        if (fechaInicio == 0 || fechaInicio > block.timestamp) {
            revert FechaInvalida();
        }

        idLote = ++totalLotes;

        lotes[idLote] = Lote({
            id: idLote,
            granja: granja,
            productor: msg.sender,
            custodio: msg.sender,
            etapa: Etapa.GranjaYCrianza,
            fechaCreacion: uint64(block.timestamp)
        });

        datosGranja[idLote] = DatosGranja({
            granja: granja,
            responsable: responsable,
            fechaInicio: fechaInicio,
            cantidadPollos: cantidadPollos
        });

        _registrar(
            idLote,
            Etapa.GranjaYCrianza,
            "Lote creado en granja"
        );

        emit LoteCreado(idLote, msg.sender, granja);
    }

    // ─── ETAPA 2: PROCESAMIENTO ──────────────────────────

    function registrarProcesamiento(
        uint256 idLote,
        string calldata plantaProcesadora,
        string calldata responsable,
        uint64 fecha,
        uint256 pesoGramos,
        string calldata controlSanitario
    ) external loteExiste(idLote) soloCustodio(idLote) {

        _avanzar(idLote, Etapa.Procesamiento);

        if (pesoGramos == 0) revert DatoInvalido();
        if (fecha == 0 || fecha > block.timestamp) {
            revert FechaInvalida();
        }

        datosProcesamiento[idLote] = DatosProcesamiento({
            plantaProcesadora: plantaProcesadora,
            responsable: responsable,
            fecha: fecha,
            pesoGramos: pesoGramos,
            controlSanitario: controlSanitario
        });

        _registrar(
            idLote,
            Etapa.Procesamiento,
            "Procesamiento del lote completado"
        );
    }

    // ─── ETAPA 3: ALMACENAMIENTO ─────────────────────────

    function registrarAlmacenamiento(
        uint256 idLote,
        string calldata almacen,
        uint64 fechaIngreso,
        string calldata responsable,
        int256 temperaturaDecimasC
    ) external loteExiste(idLote) soloCustodio(idLote) {

        _avanzar(idLote, Etapa.Almacenamiento);

        if (fechaIngreso == 0 || fechaIngreso > block.timestamp) {
            revert FechaInvalida();
        }

        datosAlmacenamiento[idLote] = DatosAlmacenamiento({
            almacen: almacen,
            fechaIngreso: fechaIngreso,
            responsable: responsable,
            temperaturaDecimasC: temperaturaDecimasC
        });

        _registrar(
            idLote,
            Etapa.Almacenamiento,
            "Lote ingresado a almacenamiento"
        );
    }

    // ─── ETAPA 4: TRANSPORTE ─────────────────────────────

    function registrarTransporte(
        uint256 idLote,
        string calldata transportista,
        string calldata origen,
        string calldata destino,
        uint64 fechaSalida,
        uint64 fechaLlegada,
        int256 temperaturaDecimasC
    ) external loteExiste(idLote) soloCustodio(idLote) {

        _avanzar(idLote, Etapa.Transporte);

        if (
            fechaSalida == 0 ||
            fechaLlegada < fechaSalida ||
            fechaLlegada > block.timestamp
        ) {
            revert FechaInvalida();
        }

        datosTransporte[idLote] = DatosTransporte({
            transportista: transportista,
            origen: origen,
            destino: destino,
            fechaSalida: fechaSalida,
            fechaLlegada: fechaLlegada,
            temperaturaDecimasC: temperaturaDecimasC
        });

        _registrar(
            idLote,
            Etapa.Transporte,
            "Transporte del lote completado"
        );
    }

    // ─── ETAPA 5: RECEPCIÓN ──────────────────────────────

    function registrarRecepcion(
        uint256 idLote,
        string calldata establecimiento,
        string calldata responsable,
        uint64 fechaRecepcion,
        uint256 cantidadRecibida,
        string calldata observaciones
    ) external loteExiste(idLote) soloCustodio(idLote) {

        _avanzar(idLote, Etapa.Recepcion);

        if (cantidadRecibida == 0) revert DatoInvalido();
        if (
            fechaRecepcion == 0 ||
            fechaRecepcion > block.timestamp
        ) {
            revert FechaInvalida();
        }

        datosRecepcion[idLote] = DatosRecepcion({
            establecimiento: establecimiento,
            responsable: responsable,
            fechaRecepcion: fechaRecepcion,
            cantidadRecibida: cantidadRecibida,
            observaciones: observaciones
        });

        _registrar(
            idLote,
            Etapa.Recepcion,
            "Lote recibido en punto de venta"
        );
    }

    // ─── Transferencia de custodia ───────────────────────

    function transferirCustodia(
        uint256 idLote,
        address nuevoCustodio
    ) external loteExiste(idLote) soloCustodio(idLote) {

        Lote storage lote = lotes[idLote];

        if (lote.etapa == Etapa.Recepcion) {
            revert LoteFinalizado(idLote);
        }

        if (nuevoCustodio == address(0)) {
            revert DireccionInvalida();
        }

        Etapa siguiente = Etapa(uint8(lote.etapa) + 1);
        Rol requerido = rolParaEtapa(siguiente);

        if (roles[nuevoCustodio] != requerido) {
            revert RolIncorrecto(
                requerido,
                roles[nuevoCustodio]
            );
        }

        emit CustodiaTransferida(
            idLote,
            msg.sender,
            nuevoCustodio
        );

        lote.custodio = nuevoCustodio;
    }

    // ─── Consultas ───────────────────────────────────────

    function obtenerLote(
        uint256 idLote
    ) external view loteExiste(idLote) returns (Lote memory) {
        return lotes[idLote];
    }

    function obtenerHistorial(
        uint256 idLote
    ) external view loteExiste(idLote) returns (Registro[] memory) {
        return historial[idLote];
    }

    function rolParaEtapa(
        Etapa etapa
    ) public pure returns (Rol) {
        return Rol(uint8(etapa) + 1);
    }

    // ─── Funciones internas ──────────────────────────────

    function _avanzar(
        uint256 idLote,
        Etapa siguiente
    ) private {

        Lote storage lote = lotes[idLote];

        if (lote.etapa == Etapa.Recepcion) {
            revert LoteFinalizado(idLote);
        }

        Etapa esperada = Etapa(uint8(lote.etapa) + 1);

        if (siguiente != esperada) {
            revert EtapaIncorrecta(esperada, siguiente);
        }

        Rol requerido = rolParaEtapa(siguiente);

        if (roles[msg.sender] != requerido) {
            revert RolIncorrecto(
                requerido,
                roles[msg.sender]
            );
        }

        lote.etapa = siguiente;
    }

    function _registrar(
        uint256 idLote,
        Etapa etapa,
        string memory detalle
    ) private {

        historial[idLote].push(
            Registro({
                etapa: etapa,
                actor: msg.sender,
                fecha: uint64(block.timestamp),
                detalle: detalle
            })
        );

        emit EtapaRegistrada(idLote, etapa, msg.sender);
    }
}