import { Container, Grid } from "semantic-ui-react";
import { useAccount } from "@starknet-react/core";
import { useTotalSupply } from "../hooks/useToken";
import Connect from "./Connect";
import Mint from "./Mint";
import Token from "./Token";

const Row = Grid.Row
const Col = Grid.Column

export default function App() {
  const { address, isConnected } = useAccount();

  const { total_supply } = useTotalSupply()

  return (
    <Container text fluid className="FillParent Relative CenteredContainer">
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
            </Col>
          </Row>
        </>}

        {isConnected && <>
          <Row columns={'equal'}>
            <Col>
              <Connect />
            </Col>
          </Row>
          <Row columns={'equal'}>
            <Col>
              <Mint />
            </Col>
          </Row>
          <Row columns={'equal'}>
            <Col>
              <div>
                Total Supply: {total_supply}
              </div>
              <Token token_id={total_supply} />
            </Col>
          </Row>
        </>}

      </Grid>

    </Container>
  );
}
