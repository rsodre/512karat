import { Button } from "semantic-ui-react";
import { useConnect, useAccount, useDisconnect } from "@starknet-react/core";
import { AddressShort } from "./AddressShort";
import { useOpener } from "../hooks/useOpener";
import ConnectModal from "./ConnectModal";

export default function Connect() {
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const { address, isConnected } = useAccount();
  const opener = useOpener()

  if (isConnected) {
    return (
      <div>
        Connected as: <AddressShort address={address ?? 0} />
        <Button onClick={() => disconnect()}>Disconnect</Button>
      </div>
    )
  }

  return (
    <div>
      <Button onClick={() => opener.open()}>Connect</Button>
      <ConnectModal opener={opener} />
    </div>
  );
}
