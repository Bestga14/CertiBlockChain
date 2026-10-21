import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import ContadorProxyModule from "./ContadorProxy.js";

// Actualiza el proxy existente a la implementación V2
export default buildModule("ContadorUpgradeModule", (m) => {
  const { proxy, contador } = m.useModule(ContadorProxyModule);

  const implV2 = m.contract("LibroV2");

  m.call(contador, "upgradeToAndCall", [implV2, "0x"]);

  const contadorV2 = m.contractAt("LibroV2", proxy, { id: "ContadorV2EnProxy" });

  return { contadorV2 };
});