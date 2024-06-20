import { Button } from "semantic-ui-react";
import { useConnect, useAccount, useDisconnect } from "@starknet-react/core";

export default function MasterAccountConnect() {
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const { address, isConnected } = useAccount();

  if (isConnected) {
    return (
      <div>
        <p>Connected with address {address}</p>
        <Button onClick={() => disconnect()}>disconnect</Button>
      </div>
    )
  }

  return (
    <ul>
      {connectors.map((connector) => (
        <li key={connector.id}>
          <Button disabled={!connector.available} onClick={() => connect({ connector })}>
            {connector.name}
          </Button>
        </li>
      ))}
    </ul>
  );
}
