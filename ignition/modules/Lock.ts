import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";


const OptoModule = buildModule("OptoModule", (m) => {
  const _owner = "0x8e251547f0fD650e0573711EF733F13eBA1505aD"
  const _router = "0xb83E47C2bC239B3bf370bc41e1459A34b41238D0"

  const opto = m.contract("Opto", [_owner, _router]);

  return { opto };
});

export default OptoModule;