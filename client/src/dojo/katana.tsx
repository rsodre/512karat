import { jsonRpcProvider } from "@starknet-react/core";
import { Chain } from "@starknet-react/chains";
import { dojoConfigKatana } from "./dojoConfig";
import { stringToFelt } from "../utils/starknet";

export const katana: Chain = {
  id: BigInt(420),
  network: "katana",
  name: "Katana Local",
  nativeCurrency: {
    address: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
    name: "Ether",
    symbol: "ETH",
    decimals: 18,
  },
  testnet: true,
  rpcUrls: {
    default: {
      http: [],
    },
    public: {
      http: ["http://localhost:5050"],
    },
  },
};

export const slot: Chain = {
  id: BigInt(stringToFelt('SLOT')),
  network: "slot",
  name: "Slot",
  nativeCurrency: {
    address: "0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7",
    name: "Ether",
    symbol: "ETH",
    decimals: 18,
  },
  testnet: true,
  rpcUrls: {
    default: {
      http: [],
    },
    public: {
      http: ["https://api.cartridge.gg/x/512karat-slot/katana"],
    },
  },
};

function rpc(chain: Chain) {
  console.log(`KATANA RPC chain:`, chain)
  return {
    nodeUrl: dojoConfigKatana.rpcUrl,
  };
}

export const katanaProvider = jsonRpcProvider({ rpc });

export function genericProvider() {
  return jsonRpcProvider({
    rpc: (chain) => {
      const nodeUrl = chain.rpcUrls.default.http[0] ?? chain.rpcUrls.public.http[0];
      console.warn(`GENERIC RPC:`, nodeUrl, chain);
      return {
        nodeUrl,
      }
    },
  });
}