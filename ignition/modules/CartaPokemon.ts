import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("CartaPokemonModule", (m) => {
    const cartaPokemon = m.contract("CartaPokemon");
    
    return {cartaPokemon};
})