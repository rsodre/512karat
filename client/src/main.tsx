import 'semantic-ui-css/semantic.min.css'
import './styles/fonts.scss'
import './styles/styles.scss'
import React from "react";
import ReactDOM from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { StarknetConfig, argent, braavos, publicProvider } from "@starknet-react/core";
import { mainnet, sepolia } from "@starknet-react/chains";
import { ArgentMobileConnector } from "starknetkit/argentMobile";
import { WebWalletConnector } from "starknetkit/webwallet";
import { katana, slot, katanaProvider, genericProvider } from "./dojo/katana.tsx";
import { makeController } from './components/useController.tsx';
import { Manifest } from '@dojoengine/core';
import manifest from "./dojo/generated//dev/manifest.json";
import App from "./components/App.tsx";

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

  const connectors = [
    controller,
    argent(),
    braavos(),
    // new InjectedConnector({ options: { id: "braavos", name: "Braavos" } }),
    // new InjectedConnector({ options: { id: "argentX", name: "Argent X" } }),
    new WebWalletConnector({ url: "https://web.argent.xyz" }),
    new ArgentMobileConnector(),
  ];

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
