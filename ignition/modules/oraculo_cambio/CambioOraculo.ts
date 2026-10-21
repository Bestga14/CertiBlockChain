import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("CambioOraculo", (m) => {
  const contrato = m.contract("CambioOraculo");

  return { contrato };
});