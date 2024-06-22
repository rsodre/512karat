import { Container, Grid } from "semantic-ui-react";
import { useAccount } from "@starknet-react/core";
import { useDebug } from "../hooks/useDebug";
import { useTokenId } from "../hooks/useTokenId";
import Connect from "./Connect";
import Mint from "./Mint";
import TokenRows from "./Token";

const Row = Grid.Row
const Col = Grid.Column

export default function App() {
  const { isDebug } = useDebug();
  const { address, isConnected } = useAccount();

  const { token_id } = useTokenId()

  return (
    <Container text className="CenteredContainer">
      <Grid>
        {/* _.⚡★tooL◆ */}

        {!isConnected && <>
          <Row columns={'equal'}>
            <Col>
              <h1>512 KARAT</h1>
            </Col>
          </Row>
          <Row columns={'equal'}>
            <Col>
              <Connect />
              {isDebug && <Mint />}
            </Col>
          </Row>
        </>}

        {isConnected && <>
          <Row columns={'equal'}>
            <Col>
              <Connect />
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
        </>}

        {(isDebug || isConnected) && <TokenRows token_id={token_id} />}

      </Grid>

    </Container>
  );
}
