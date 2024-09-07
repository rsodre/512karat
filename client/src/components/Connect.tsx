import { Button, Grid } from "semantic-ui-react";
import { useConnect, useAccount, useDisconnect } from "@starknet-react/core";
import { AddressShort } from "./ui/AddressShort";
import { useOpener } from "../hooks/useOpener";
import ConnectModal from "./ConnectModal";
import { feltToString } from "../utils/starknet";
import { IconClick } from "./ui/Icons";

const Row = Grid.Row
const Col = Grid.Column

export function ConnectButton() {
  const { isConnected } = useAccount();
  const opener = useOpener()

  return (
    <div>
      <Button disabled={isConnected} onClick={() => opener.open()}>Connect</Button>
      <ConnectModal opener={opener} />
    </div>
  );
}

export function DisconnectButton() {
  const { disconnect } = useDisconnect();
  const { isConnected } = useAccount();
  return (
    <div>
      <Button disabled={!isConnected} onClick={() => disconnect()}>Disconnect</Button>
    </div>
  )
}

export function DisconnectIcon() {
  const { disconnect } = useDisconnect();
  const { isConnected } = useAccount();
  return (
    <IconClick name='sign-out' disabled={!isConnected} onClick={() => disconnect()} />
  )
}

export function ConnectedHeader() {
  const { address, chainId, isConnected } = useAccount();
  if (!isConnected) return <></>
  return (
    <Grid>
      <Row columns={'equal'}>
        <Col textAlign="left" verticalAlign="middle">
          <AddressShort address={address ?? 0} />
        </Col>
        <Col textAlign="right" verticalAlign="middle">
          {chainId ? feltToString(chainId) : '[chain]'}
          {' '}
          <DisconnectIcon />
        </Col>
      </Row>
    </Grid>
  )
}
