// Lo ejecuta: Productor
import { network } from "hardhat";
import { parseEventLogs, zeroHash } from "viem";
import { DIRECCION_CONTRATO } from "./config.js";

const ORIGEN = "Granja Sofia 1, Santa Cruz";
const DETALLE = "Nacimiento 2025, variedad normal, 2 kg";

const { viem } = await network.connect();

const publicClient = await viem.getPublicClient();
const [yo] = await viem.getWalletClients();

const cafe = await viem.getContractAt("Pollo", DIRECCION_CONTRATO);

const hash = await cafe.write.crearLote([ORIGEN,  DETALLE]);
const recibo = await publicClient.waitForTransactionReceipt({ hash });

// El ID del lote se obtiene del evento LoteCreado
const [evento] = parseEventLogs({ abi: cafe.abi, logs: recibo.logs, eventName: "LoteCreado" });
console.log(`✔ Lote creado por ${yo.account.address}`);
console.log(`  ID del lote: ${evento.args.idLote}  ← compártelo con el grupo`);