import 'semantic-ui-css/semantic.min.css'
import './styles/fonts.scss'
import './styles/styles.scss'
import React from "react";
import ReactDOM from "react-dom/client";
import { createBrowserRouter, RouterProvider } from "react-router-dom";
import { StarknetConfig, argent, braavos } from "@starknet-react/core";
import { mainnet, sepolia } from "@starknet-react/chains";
import { ArgentMobileConnector } from "starknetkit/argentMobile";
import { WebWalletConnector } from "starknetkit/webwallet";
import { setup } from "./dojo/generated/setup.ts";
import { DojoProvider } from "./dojo/DojoContext.tsx";
import { dojoConfig } from "./dojo/dojoConfig.ts";
import { provider, katana } from "./dojo/katana.tsx";
import { makeController } from './components/useController.tsx';
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

  const setupResult = await setup(dojoConfig);

  const controller = makeController(setupResult.manifest)

  const chains = [
    katana,
    // sepolia,
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
        provider={() => provider(katana)}
        connectors={connectors}
        autoConnect={false}
      >
        <DojoProvider value={setupResult}>
          <RouterProvider router={router} />
        </DojoProvider>
      </StarknetConfig>
    </React.StrictMode>
  );
}

init();
