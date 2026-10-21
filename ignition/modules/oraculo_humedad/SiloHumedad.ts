import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// dirección del oráculo de Chainlink ETH/USD en la red Sepolia
const ORACULO_ETH_USD_SEPOLIA = "0x4FF2F4F4BD5bE35663B7021CdE7d0E5B086C3099";

export default buildModule("SiloModule", (m) => {
  const bodega = m.contract("GuardarEnBodega", [ORACULO_ETH_USD_SEPOLIA]);
  return { bodega };
});