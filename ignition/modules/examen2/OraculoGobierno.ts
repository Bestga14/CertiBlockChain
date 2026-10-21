import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("OraculoGobiernoModule", (m) => {
  const contrato = m.contract("OraculoGobierno");

  return { contrato };
});