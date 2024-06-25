import { LOCAL_KATANA, LOCAL_TORII, createDojoConfig } from "@dojoengine/core";
import { PredeployedAccount } from "@dojoengine/create-burner";
import { Chain } from "@starknet-react/chains";
import manifest_dev from "./generated/dev/manifest.json";
import manifest_slot from "./generated/slot/manifest.json";
import manifest_sepolia from "./generated/sepolia/manifest.json";

export const dojoConfigKatana = createDojoConfig({
  manifest: manifest_dev,
  rpcUrl: LOCAL_KATANA,
  masterAddress: '0xb3ff441a68610b30fd5e2abbf3a1548eb6ba6f3559f2862bf2dc757e5828ca',
  masterPrivateKey: '0x2bbf4f9fd0bbb2e60b0316c1fe0b76cf7a4d0198bd493ced9b8df2a3a24d68a',
});

const dojoConfigSlot = createDojoConfig({
  manifest: manifest_slot,
  rpcUrl: 'https://api.cartridge.gg/x/512karat-slot/katana',
  toriiUrl: 'https://api.cartridge.gg/x/512karat-slot/torii',
  masterAddress: '0x5c386e2791e4ba6268c80d2a6dee77e0de33be5bbf4a05a603dac9cfb9cecb3',
  masterPrivateKey: '0x572781c71db23ea3b4b701ff11764919c8d7917d8460aebd35196309fed19b8',
});

const dojoConfigSepolia = createDojoConfig({
  manifest: manifest_sepolia,
  rpcUrl: 'https://api.cartridge.gg/rpc/starknet-sepolia',
  toriiUrl: 'https://api.cartridge.gg/x/512karat-sepolia/torii',
  // masterAddress: '0x0',
  // masterPrivateKey: '0x0',
});

export const getDojoConfig = (chain: Chain) => {
  return (
    chain.network == 'sepolia' ? dojoConfigSepolia
      : chain.network == 'slot' ? dojoConfigSlot
        : dojoConfigKatana
  )
}

export const getPredeployedAccounts = (config: typeof dojoConfigKatana): PredeployedAccount[] => {
  return (config.masterAddress && config.masterPrivateKey) ? [{
    name: 'Master Account',
    address: config.masterAddress,
    privateKey: config.masterPrivateKey,
    active: false,
  }] : []
}
