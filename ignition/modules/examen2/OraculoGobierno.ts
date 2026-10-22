import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("OraculoGobiernoModule1", (m) => {
  const contrato = m.contract("OraculoGobierno");

  return { contrato };
});