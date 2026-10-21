import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("HumedadOraculo", (m) => {
  const contrato = m.contract("HumedadOraculo");

  return { contrato };
});