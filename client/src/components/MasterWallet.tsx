import { useConnect, useAccount, useDisconnect } from "@starknet-react/core";

export default function MasterAccountConnect() {
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const { address, isConnected } = useAccount();

  if (isConnected) {
    return (
      <div>
        <p>Connected with address {address}</p>
        <button onClick={() => disconnect()}>disconnect</button>
      </div>
    )
  }

  return (
    <ul>
      {connectors.map((connector) => (
        <li key={connector.id}>
          <button disabled={!connector.available} onClick={() => connect({ connector })}>
            {connector.name}
          </button>
        </li>
      ))}
    </ul>
  );
}
