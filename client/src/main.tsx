import 'semantic-ui-css/semantic.min.css'
import './styles/fonts.scss'
import './styles/styles.scss'
import React from "react";
import ReactDOM from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { StarknetConfig, argent, braavos, injected, jsonRpcProvider } from "@starknet-react/core";
// import { ArgentMobileConnector } from "starknetkit/argentMobile";
// import { WebWalletConnector } from "starknetkit/webwallet";
import { StarknetWindowObject } from "get-starknet-core";
import { RpcProvider } from 'starknet';
import { DojoPredeployedStarknetWindowObject, PredeployedManager } from '@dojoengine/create-burner'
import { defaultChainId, getDojoChainConfig } from './dojo/dojoConfig.ts';
import { makeController } from './hooks/useController.tsx';
import { isPositiveBigint } from './utils/types.tsx';
import App from "./components/App.tsx";


const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
  },
]);

export function genericProvider() {
  return jsonRpcProvider({
    rpc: (chain) => {
      const nodeUrl = chain.rpcUrls.default.http[0] ?? chain.rpcUrls.public.http[0];
      // console.warn(`GENERIC RPC:`, nodeUrl, chain);
      return {
        nodeUrl,
      }
    },
  });
}

async function init() {
  const rootElement = document.getElementById("root");
  if (!rootElement) throw new Error("React root not found");
  const root = ReactDOM.createRoot(rootElement as HTMLElement);

  const dojoChainConfig = getDojoChainConfig(defaultChainId)

  const controller = makeController(
    dojoChainConfig.dojoConfig.manifest,
    dojoChainConfig.dojoConfig.rpcUrl,
    'karat',
    {
      minter: ['IMinter'],
    },
  )

  const chains = [
    dojoChainConfig.chain,
  ];

  let connectors = [
    controller,
    argent(),
    braavos(),
    // new InjectedConnector({ options: { id: "braavos", name: "Braavos" } }),
    // new InjectedConnector({ options: { id: "argentX", name: "Argent X" } }),
    // new WebWalletConnector({ url: "https://web.argent.xyz" }),
    // new ArgentMobileConnector(),
  ];

  //
  // ONLY ON KATANA: create predeployed connector for testing
  try {
    const katana = dojoChainConfig.dojoConfig
    console.log(`KATANA:::`, defaultChainId, katana)
    if (isPositiveBigint(katana.masterAddress) && isPositiveBigint(katana.masterPrivateKey)){
      const predeployedManager = new PredeployedManager({
        rpcProvider: new RpcProvider({ nodeUrl: katana.rpcUrl }),
        predeployedAccounts: [{
          name: 'Master Account',
          address: katana.masterAddress,
          privateKey: katana.masterPrivateKey,
          active: false,
        }],
      });
      await predeployedManager.init();
      // cloned from usePredeployedWindowObject()...
      const predeployedWindowObject = new DojoPredeployedStarknetWindowObject(predeployedManager);
      const key = `starknet_${predeployedWindowObject.id}`;
      (window as any)[key as string] = predeployedWindowObject as StarknetWindowObject;
      connectors.push(injected({ id: predeployedWindowObject.id }))
    }
  } catch { }


  root.render(
    <React.StrictMode>
      <StarknetConfig
        chains={chains}
        provider={genericProvider()}
        connectors={connectors}
        autoConnect={true}
      >
        <RouterProvider router={router} />
      </StarknetConfig>
    </React.StrictMode>
  );
}

init();
