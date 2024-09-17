import { useMemo } from "react";
import { Divider, Grid, Icon, Image } from "semantic-ui-react";
import { useTokenOwner } from "../hooks/useToken";
import { useTokenUri } from "../hooks/useTokenUri";
import { AddressShort } from "./ui/AddressShort";
import { useStateContext } from "../hooks/StateContext";

const Row = Grid.Row
const Col = Grid.Column

export default function InfoPanel() {


  return (
    <>
      <Divider />
      <Grid>
        <Row columns={'equal'}>
          <Col>
            <p>
              <b>Karat</b> is a fully on-chain generative art project
              <br />made with <a href='https://dojoengine.org'>Dojo</a>, a game engine for Starknet.
              </p>
            <p>This is a <b>FREE</b> mint, costing only gas.<br />Around... less than 0.5 cents!</p>
            <p>
              The max supply is <b>512 tokens</b>,
              <br />25% was minted at the Dojo Residency in NYC,
              <br />the remaining tokens will be whitelisted
              <br />to select communities.
            </p>
            <p>
              And it's <a href='https://github.com/rsodre/512karat'>open-source</a>!
              <br />Let's make generative art on Starknet!
            </p>
          </Col>
        </Row>
      </Grid>
    </>
  );
}
