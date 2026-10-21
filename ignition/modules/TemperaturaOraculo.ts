import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("TemperaturaOraculoModule", (m) => {
  const contrato = m.contract("TemperaturaOraculo");

  return { contrato };
});