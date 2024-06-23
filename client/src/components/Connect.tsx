import { Button, Grid } from "semantic-ui-react";
import { useConnect, useAccount, useDisconnect } from "@starknet-react/core";
import { AddressShort } from "./AddressShort";
import { useOpener } from "../hooks/useOpener";
import ConnectModal from "./ConnectModal";
import { feltToString } from "../utils/starknet";

const Row = Grid.Row
const Col = Grid.Column

export function Connect() {
  const { isConnected } = useAccount();
  const opener = useOpener()

  return (
    <div>
      <Button disabled={isConnected} onClick={() => opener.open()}>Connect</Button>
      <ConnectModal opener={opener} />
    </div>
  );
}

export function Disconnect() {
  const { disconnect } = useDisconnect();
  const { isConnected } = useAccount();
  return (
    <div>
      <Button disabled={!isConnected} onClick={() => disconnect()}>Disconnect</Button>
    </div>
  )
}

export function ConnectedHeader() {
  const { disconnect } = useDisconnect();
  const { address, chainId } = useAccount();

  return (
    <Grid>
      <Row columns={'equal'}>
        <Col textAlign="left" verticalAlign="middle">
          <AddressShort address={address ?? 0} />
        </Col>
        <Col textAlign="right" verticalAlign="middle">
          {chainId ? feltToString(chainId) : '[chain]'}
        </Col>
      </Row>
    </Grid>
  )
}
