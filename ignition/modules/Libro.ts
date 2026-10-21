import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("LibroModule", (m) => {
    const libro = m.contract("Libro");
    
    return {libro};
})