import 'semantic-ui-css/semantic.min.css'
import './styles/fonts.scss'
import './styles/styles.scss'
import React from "react";
import ReactDOM from "react-dom/client";
import { setup } from "./dojo/generated/setup.ts";
import { DojoProvider } from "./dojo/DojoContext.tsx";
import { dojoConfig } from "./dojo/dojoConfig.ts";
import { sepolia } from "@starknet-react/chains";
import { StarknetConfig, argent, braavos } from "@starknet-react/core";
import { provider, katana } from "./dojo/katana.tsx";
import App from "./components/App.tsx";

async function init() {
  const rootElement = document.getElementById("root");
  if (!rootElement) throw new Error("React root not found");
  const root = ReactDOM.createRoot(rootElement as HTMLElement);

  const setupResult = await setup(dojoConfig);

  const chains = [katana];

  const connectors = [braavos(), argent()];

  root.render(
    <React.StrictMode>
      <StarknetConfig
        chains={chains}
        provider={() => provider(katana)}
        connectors={connectors}
        autoConnect={false}
      >
        <DojoProvider value={setupResult}>
          <App />
        </DojoProvider>
      </StarknetConfig>
    </React.StrictMode>
  );
}

init();
