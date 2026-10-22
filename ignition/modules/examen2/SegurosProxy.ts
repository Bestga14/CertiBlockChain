import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const ORACULO = "0xc6f6C1D2194080d8Cf8EB44a3c1C00BF0Ca9bf0F";

export default buildModule("SegurosProxyModule01", (m) => {
  const owner = m.getAccount(0);

  const implV1 = m.contract("ContratoSeguros");

  const datosInit = m.encodeFunctionCall(implV1, "initialize", [owner, ORACULO]);

  const proxy = m.contract("SegurosProxy", [implV1, datosInit]);

  const contratoSeguros = m.contractAt("SegurosProxy", proxy, { id: "SegurosEnProxy" });

  return { proxy, contratoSeguros };
});