import React, { ReactNode, useEffect, useState } from "react";
import { useNetwork } from "@starknet-react/core";
import { setup, SetupResult } from "./generated/setup.ts";
import { DojoProvider } from "./DojoContext.tsx";
import { getDojoChainConfig } from "./dojoConfig.ts";

export default function DojoSetup({
  children,
}: {
  children: ReactNode;
}) {
  const { chain } = useNetwork();
  const [setupResult, setSetupResult] = useState<SetupResult>()

  // avoid strict react double mount at first mount
  const [mounted, setMounted] = useState(false)
  useEffect(() => {
    setMounted(true)
  }, [])

  useEffect(() => {
    const _setup = async () => {
      console.log(`Setup Dojo for chain...`, chain)
      const dojoConfig = getDojoChainConfig(chain.id).dojoConfig
      const result = await setup(dojoConfig);
      console.log(`SetupResult:`, result)
      setSetupResult(result);
    }
    setSetupResult(undefined);
    if (chain && mounted) {
      _setup();
    }
  }, [chain, mounted])

  if (!setupResult) {
    return (
      <div>
        <h5>loading...</h5>
      </div>
    )
  }

  return (
    <DojoProvider value={setupResult}>
      {children}
    </DojoProvider>
  );
}
