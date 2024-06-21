import { Button, Grid } from "semantic-ui-react";
import { useConnect, useAccount, useDisconnect } from "@starknet-react/core";
import { AddressShort } from "./AddressShort";
import { useOpener } from "../hooks/useOpener";
import ConnectModal from "./ConnectModal";

const Row = Grid.Row
const Col = Grid.Column

export default function Connect() {
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const { address, isConnected } = useAccount();
  const opener = useOpener()

  if (isConnected) {
    return (
      <Grid>
        <Row columns={'equal'}>
          <Col textAlign="left">
            <Button onClick={() => disconnect()}>Disconnect</Button>
          </Col>
          <Col textAlign="right" verticalAlign="middle">
            <AddressShort address={address ?? 0} />
          </Col>
        </Row>
      </Grid>
    )
  }

  return (
    <div>
      <Button onClick={() => opener.open()}>Connect</Button>
      <ConnectModal opener={opener} />
    </div>
  );
}
