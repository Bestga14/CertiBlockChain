import { network } from "hardhat";

const { viem } = await network.connect();
const publicClient = await viem.getPublicClient();

const libro = await viem.getContractAt(
  "Libro",
  "0xAB7E96F702EA49F53f44885BEa47109AF1DB54Bb"
);

const hash = await libro.write.venderLibro([15n, "0xc942AD305F917C2d3b7bA30A1A0ec2efbb6Fe045"]);

console.log("Transacción enviada:", hash);

// 2. Esperar a que se confirme
const recibo = await publicClient.waitForTransactionReceipt({ hash });
if (recibo.status !== "success") {
  throw new Error("La transacción falló");
}
console.log("Libro generado en el bloque", recibo.blockNumber);

// 3. Leer (con await)
const factura = await libro.read.obtenerLibro([15n]);

console.log("Libro Generado");
console.log("Libro:", factura);