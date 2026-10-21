import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const ORACULO = "";
// Despliega la implementación V1 y el proxy que apunta a ella
export default buildModule("sEGUROSProxyModule", (m) => {
  const owner = m.getAccount(0);

  const implV1 = m.contract("ContratoSeguros", , [ORACULO]);

  // Codifica la llamada initialize(owner) para ejecutarla al crear el proxy
  const datosInit = m.encodeFunctionCall(implV1, "initialize", [owner]);

  const proxy = m.contract("SegurosProxy", [implV1, datosInit]);

  // El mismo proxy, visto con el ABI de V1
  const contador = m.contractAt("ContratoSeguros", proxy, { id: "SegurosEnProxy" });

  return { proxy, contador };
});