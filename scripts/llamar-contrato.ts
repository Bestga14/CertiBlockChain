import { network } from "hardhat";

const { viem } = await network.connect();

const counter = await viem.getContractAt(
    "Counter",
    //"0x5FbDB2315678afecb367f032d93F642f64180aa3" // tu dirección
    //"0x1A910544ee6b1c24a75d97387aE9Acdaa906E0D3"
    "0x168C19abFEAbAFF2a0EEe0C94FF505Fc7d8aA25B"
);

console.log("Valor inicial: ", await counter.read.x());

await counter.write.inc();   // Llama al método que incrementa en 1
//await counter.write.incBy([10n]); // llama al método que incrementa en 10

console.log("Valor final: ", await counter.read.x());