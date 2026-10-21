import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("PolloModule", (m) => {
  const contrato = m.contract("Pollo");

  return { contrato };
});