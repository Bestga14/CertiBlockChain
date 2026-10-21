import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("VidaOraculo", (m) => {
  const contrato = m.contract("VidaOraculo");

  return { contrato };
});