import { createDojoConfig } from "@dojoengine/core";
import manifest_dev from "./generated/dev/manifest.json";
import manifest_sepolia from "./generated/sepolia/manifest.json";

export const dojoConfigKatana = createDojoConfig({
  manifest: manifest_dev,
  masterAddress: '0xb3ff441a68610b30fd5e2abbf3a1548eb6ba6f3559f2862bf2dc757e5828ca',
  masterPrivateKey: '0x2bbf4f9fd0bbb2e60b0316c1fe0b76cf7a4d0198bd493ced9b8df2a3a24d68a',
});

export const dojoConfigSepolia = createDojoConfig({
  manifest: manifest_sepolia,
  rpcUrl: 'https://api.cartridge.gg/rpc/starknet-sepolia',
  toriiUrl: 'https://api.cartridge.gg/x/512karat/torii',
  // masterAddress: '0x0',
  // masterPrivateKey: '0x0',
});
