import { network } from "hardhat";

const { viem } = await network.connect();
const publicClient = await viem.getPublicClient();

const facturacion = await viem.getContractAt(
  "Facturacion",
  "0x03B28eE4a7237A763BaD6Bb0fA3540a683f5474e"
);

const hash = await facturacion.write.facturar([5n, "0xc942AD305F917C2d3b7bA30A1A0ec2efbb6Fe045", 1000n]);

console.log("Transacción enviada:", hash);

// 2. Esperar a que se confirme
const recibo = await publicClient.waitForTransactionReceipt({ hash });
if (recibo.status !== "success") {
  throw new Error("La transacción falló");
}
console.log("Factura generada en el bloque", recibo.blockNumber);

// 3. Leer (con await)
const factura = await facturacion.read.obtenerFactura([5n]);

console.log("Factura Generado");
console.log("Factura:", factura);