import { network } from "hardhat";

const { viem } = await network.connect();
const publicClient = await viem.getPublicClient();

const cartaPokemon = await viem.getContractAt(
  "cartaPokemon",
  "0x03B28eE4a7237A763BaD6Bb0fA3540a683f5474e"
);

const hash = await cartaPokemon.write.iincrementarMazo([1n, "0x168C19abFEAbAFF2a0EEe0C94FF505Fc7d8aA25B", 244n, 1000n]);

console.log("Transacción enviada:", hash);

// 2. Esperar a que se confirme
const recibo = await publicClient.waitForTransactionReceipt({ hash });
if (recibo.status !== "success") {
  throw new Error("La transacción falló");
}
console.log("Carta generada en el bloque", recibo.blockNumber);

// 3. Leer (con await)
const factura = await cartaPokemon.read.obtenerFactura([5n]);

console.log("Carta Generado");
console.log("Carta:", factura);