import { Container, Grid } from "semantic-ui-react";
import { useAccount } from "@starknet-react/core";
import { useTotalSupply } from "../hooks/useToken";
import { useDebug } from "../hooks/useDebug";
import Connect from "./Connect";
import Mint from "./Mint";
import TokenRows from "./Token";

const Row = Grid.Row
const Col = Grid.Column

export default function App() {
  const { isDebug } = useDebug();
  const { address, isConnected } = useAccount();

  const { total_supply } = useTotalSupply()

  return (
    <Container text>
      <Grid>

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
          {isDebug && <TokenRows token_id={total_supply} />}
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
          
          <TokenRows token_id={total_supply} />
        </>}

      </Grid>

    </Container>
  );
}
