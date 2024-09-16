import { DojoConfig, KATANA_ETH_CONTRACT_ADDRESS, LOCAL_KATANA, LOCAL_TORII, createDojoConfig } from "@dojoengine/core";
import { Chain, NativeCurrency, sepolia as sn_sepolia, mainnet as sn_mainnet } from "@starknet-react/chains";
import manifest_dev from "./generated/dev/manifest.json";
import manifest_slot from "./generated/slot/manifest.json";
import manifest_sepolia from "./generated/sepolia/manifest.json";
import manifest_mainnet from "./generated/mainnet/manifest.json";
import { feltToString, stringToFelt } from "../utils/starknet";

export const defaultChainId: ChainId = import.meta.env.VITE_PUBLIC_CHAIN_ID as ChainId;

if (!defaultChainId) {
  throw new Error('VITE_PUBLIC_CHAIN_ID must be set')
}

//--------------------------------
// Dojo Configs
//

export const dojoConfigKatana: DojoConfig = createDojoConfig({
  manifest: manifest_dev,
  rpcUrl: LOCAL_KATANA,
  masterAddress: '0xb3ff441a68610b30fd5e2abbf3a1548eb6ba6f3559f2862bf2dc757e5828ca',
  masterPrivateKey: '0x2bbf4f9fd0bbb2e60b0316c1fe0b76cf7a4d0198bd493ced9b8df2a3a24d68a',
});

export const dojoConfigSlot: DojoConfig = createDojoConfig({
  manifest: manifest_slot,
  rpcUrl: 'https://api.cartridge.gg/x/512karat-slot/katana',
  toriiUrl: 'https://api.cartridge.gg/x/512karat-slot/torii',
  masterAddress: '0x5c386e2791e4ba6268c80d2a6dee77e0de33be5bbf4a05a603dac9cfb9cecb3',
  masterPrivateKey: '0x572781c71db23ea3b4b701ff11764919c8d7917d8460aebd35196309fed19b8',
});

const dojoConfigSepolia: DojoConfig = createDojoConfig({
  manifest: manifest_sepolia,
  rpcUrl: 'https://api.cartridge.gg/x/starknet/sepolia',
  toriiUrl: 'https://api.cartridge.gg/x/512karat-sepolia/torii',
  // masterAddress: '0x0',
  // masterPrivateKey: '0x0',
});

const dojoConfigMainnet: DojoConfig = createDojoConfig({
  manifest: manifest_mainnet,
  rpcUrl: 'https://api.cartridge.gg/x/starknet/mainnet',
  toriiUrl: 'https://api.cartridge.gg/x/karat-mainnet/torii',
  masterAddress: '0x0',
  masterPrivateKey: '0x0',
});


//--------------------------------
// Starkent Chains
//

export enum ChainId {
  KATANA_LOCAL = 'KATANA_LOCAL',
  KARAT_SLOT = 'WP_KARAT_SLOT',
  SN_SEPOLIA = 'SN_SEPOLIA',
  SN_MAIN = 'SN_MAIN',
}

const ETH_KATANA: NativeCurrency = {
  address: KATANA_ETH_CONTRACT_ADDRESS,
  name: 'Ether',
  symbol: 'ETH',
  decimals: 18,
}

export const katana: Chain = {
  id: BigInt(stringToFelt(ChainId.KATANA_LOCAL)),
  network: "katana",
  name: "Katana Local",
  nativeCurrency: ETH_KATANA,
  testnet: true,
  rpcUrls: {
    default: { http: [dojoConfigKatana.rpcUrl] },
    public: { http: [dojoConfigKatana.rpcUrl] },
  },
};

export const slot: Chain = {
  id: BigInt(stringToFelt(ChainId.KARAT_SLOT)),
  network: "slot",
  name: "Slot",
  nativeCurrency: ETH_KATANA,
  testnet: true,
  rpcUrls: {
    default: { http: [dojoConfigSlot.rpcUrl] },
    public: { http: [dojoConfigSlot.rpcUrl] },
  },
};

export const sepolia: Chain = {
  ...sn_sepolia,
  rpcUrls: {
    default: { http: [dojoConfigSepolia.rpcUrl] },
    public: { http: [dojoConfigSepolia.rpcUrl] },
  },
};

export const mainnet: Chain = {
  ...sn_mainnet,
  rpcUrls: {
    default: { http: [dojoConfigMainnet.rpcUrl] },
    public: { http: [dojoConfigMainnet.rpcUrl] },
  },
};

//--------------------------------
// Chain mapping
//

export type DojoChainConfig = {
  chain: Chain
  dojoConfig: DojoConfig
}

export const dojoContextConfig: Record<ChainId, DojoChainConfig> = {
  [ChainId.KATANA_LOCAL]: {
    chain: katana,
    dojoConfig: dojoConfigKatana,
  },
  [ChainId.KARAT_SLOT]: {
    chain: slot,
    dojoConfig: dojoConfigSlot,
  },
  [ChainId.SN_SEPOLIA]: {
    chain: sepolia,
    dojoConfig: dojoConfigSepolia,
  },
  [ChainId.SN_MAIN]: {
    chain: mainnet,
    dojoConfig: dojoConfigMainnet,
  },
}


export const getDojoChainConfig = (chainId: bigint | ChainId): DojoChainConfig => {
  return dojoContextConfig[
    typeof chainId === 'bigint' ? feltToString(chainId) as ChainId : chainId
  ]
}
