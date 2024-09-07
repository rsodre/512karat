import { Container, Divider, Grid, Image } from "semantic-ui-react";
import { useAccount } from "@starknet-react/core";
import { useDebug } from "../hooks/useDebug";
import { ConnectedHeader, ConnectButton } from "./Connect";
import MintButton from "./MintButton";
import DojoSetup from "../dojo/DojoSetup";
import Main from "./Main";

const Row = Grid.Row
const Col = Grid.Column

export default function App() {
  const { isDebug } = useDebug();
  const { isConnected } = useAccount();

  return (
    <DojoSetup>
      <Container text className="CenteredContainer">

        {/* _.⚡★tooL◆ */}
        <Grid>

          <Row columns={'equal'}>
            <Col>
              <ConnectedHeader />
            </Col>
          </Row>
          <Row>
            <Col textAlign="left" width={10}>
              <h1>512 KARAT</h1>
            </Col>
            <Col textAlign="right" width={6}>
              {!isConnected && <ConnectButton />}
              {isConnected && <MintButton />}
            </Col>
          </Row>

          <Row columns={'equal'}>
            <Col>
              <Divider />
            </Col>
          </Row>

          <Row columns={1} className="NoPadding NoMargin NoBorder">
            <Col>
              <Main />
            </Col>
          </Row>

          <Row columns={'equal'}>
            <Col>
              <Divider />
            </Col>
          </Row>

          <Row columns={'equal'}>
            <Col>
              Fully on-chain Generative Art made with <a href='https://dojoengine.org'>Dojo</a> on <a href='http://starknet.io'>Starknet</a>
              <br />
              <a href='https://x.com/matalecode'>@matalecode</a> / <a href='http://collect-code.com'>collect-code</a>
            </Col>
          </Row>

        </Grid>

      </Container >
    </DojoSetup>
  );
}
