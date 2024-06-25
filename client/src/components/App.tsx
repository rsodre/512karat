import { Container, Divider, Grid, Image } from "semantic-ui-react";
import { useAccount } from "@starknet-react/core";
import { useDebug } from "../hooks/useDebug";
import { Connect, Disconnect, ConnectedHeader } from "./Connect";
import DojoSetup from "../dojo/DojoSetup";
import Mint from "./Mint";
import TokenRows from "./Token";

const Row = Grid.Row
const Col = Grid.Column

export default function App() {
  const { isDebug } = useDebug();
  const { address, isConnected } = useAccount();

  return (
    <Container text className="CenteredContainer">

      {/* _.⚡★tooL◆ */}

      {!isConnected &&
        <Grid>
          <Col textAlign="left" width={10}>
            <h1>512 KARAT</h1>
          </Col>
          <Col textAlign="right" width={6}>
            <Connect />
          </Col>
          <Row columns={'equal'}>
            <Col>
              <Image src={'/images/home.svg'} size='large' centered spaced />
            </Col>
          </Row>
          <Row columns={'equal'}>
            <Col>
              Fully on-chain Generative Art made with <a href='https://dojoengine.org'>Dojo</a> on <a href='http://starknet.io'>Starknet</a>
              <br />
              <a href='https://x.com/matalecode'>@mataleocode</a> / <a href='http://collect-code.com'>collect-code</a>
            </Col>
          </Row>
        </Grid>
      }

      {isConnected &&
        <DojoSetup>
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
                <Mint />
              </Col>
            </Row>

            <TokenRows />

            <Row columns={'equal'}>
              <Col>
                <Divider hidden />
                <Disconnect />
              </Col>
            </Row>
          </Grid>
        </DojoSetup>
      }

      <Divider hidden />

    </Container >
  );
}
