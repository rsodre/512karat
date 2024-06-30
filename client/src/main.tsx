import 'semantic-ui-css/semantic.min.css'
import './styles/fonts.scss'
import './styles/styles.scss'
import React from "react";
import ReactDOM from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { StarknetConfig, argent, braavos, injected, publicProvider } from "@starknet-react/core";
import { mainnet, sepolia } from "@starknet-react/chains";
import { ArgentMobileConnector } from "starknetkit/argentMobile";
import { WebWalletConnector } from "starknetkit/webwallet";
import { StarknetWindowObject } from "get-starknet-core";
import { RpcProvider } from 'starknet';
import { katana, slot, katanaProvider, genericProvider } from "./dojo/katana.tsx";
import { DojoPredeployedStarknetWindowObject, PredeployedManager } from '@dojoengine/create-burner'
import { makeController } from './components/useController.tsx';
import { Manifest } from '@dojoengine/core';
import manifest from "./dojo/generated//dev/manifest.json";
import App from "./components/App.tsx";
import { dojoConfigKatana, getPredeployedAccounts } from './dojo/dojoConfig.ts';

const router = createBrowserRouter([
  {
    path: "/",
    element: <App />,
  },
]);

async function init() {
  const rootElement = document.getElementById("root");
  if (!rootElement) throw new Error("React root not found");
  const root = ReactDOM.createRoot(rootElement as HTMLElement);

  // TODO: should be by chain!
  const controller = makeController(manifest as Manifest)

  const chains = [
    katana,
    slot,
    sepolia,
    // mainnet,
  ];

  let connectors = [
    controller,
    argent(),
    braavos(),
    // new InjectedConnector({ options: { id: "braavos", name: "Braavos" } }),
    // new InjectedConnector({ options: { id: "argentX", name: "Argent X" } }),
    new WebWalletConnector({ url: "https://web.argent.xyz" }),
    new ArgentMobileConnector(),
  ];

  //
  // create Katana connector for testing
  const predeployedManager = new PredeployedManager({
    rpcProvider: new RpcProvider({ nodeUrl: dojoConfigKatana.rpcUrl }),
    predeployedAccounts: getPredeployedAccounts(dojoConfigKatana),
  });
  await predeployedManager.init();
  try {
    // cloned from usePredeployedWindowObject()...
    const predeployedWindowObject = new DojoPredeployedStarknetWindowObject(predeployedManager);
    const key = `starknet_${predeployedWindowObject.id}`;
    (window as any)[key as string] = predeployedWindowObject as StarknetWindowObject;
    connectors.push(injected({ id: predeployedWindowObject.id }))
  } catch {}


  root.render(
    <React.StrictMode>
      <StarknetConfig
        chains={chains}
        // provider={() => katanaProvider(katana)}
        provider={genericProvider()}
        connectors={connectors}
        autoConnect={false}
      >
        <RouterProvider router={router} />
      </StarknetConfig>
    </React.StrictMode>
  );
}

init();
