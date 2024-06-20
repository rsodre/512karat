import { Container } from "semantic-ui-react";
import { useDojo } from "../dojo/useDojo";
import { useTotalSupply } from "../hooks/useToken";
import { Deploy } from "./Deploy";
import MasterAccountConnect from "./MasterWallet";
import Mint from "./Mint";
import Token from "./Token";
import { shortAddress } from "../utils/types";
import { AddressShort } from "./AddressShort";

export default function App() {
  const { account } = useDojo();

  const { total_supply } = useTotalSupply()

  return (
    <Container text>
      <Deploy />
      <MasterAccountConnect />

      <div className="card">
        account: <AddressShort address={account?.address ?? 0} />
      </div>

      <div className="card">
        <Mint />
        <div>
          Total Supply: {total_supply}
        </div>
        <Token token_id={total_supply} />
      </div>

    </Container>
  );
}
