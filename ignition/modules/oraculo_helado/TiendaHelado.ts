import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

// dirección del oráculo de Chainlink ETH/USD en la red Sepolia
const ORACULO_TEMPERATURA = "0x2CAc1dB647B421bcFBeF90A610973Cb6ac605E37";
const ORACULO_HUMEDAD = "0x4FF2F4F4BD5bE35663B7021CdE7d0E5B086C3099";
const ORACULO_ETH_USD_SEPOLIA = "0x694AA1769357215DE4FAC081bf1f309aDC325306";

export default buildModule("TiendaHeladoModuleV3", (m) => {
  const bodega = m.contract("TiendaHelado", [ORACULO_TEMPERATURA, ORACULO_HUMEDAD, ORACULO_ETH_USD_SEPOLIA]);
  return { bodega };
});