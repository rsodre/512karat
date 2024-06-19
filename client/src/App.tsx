import { useEffect, useState } from "react";
import { useComponentValue } from "@dojoengine/react";
import { Entity } from "@dojoengine/recs";
import "./App.css";
import { Direction } from "./utils";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useDojo } from "./dojo/useDojo";
import MasterAccountConnect from "./components/MasterWallet";
import { Deploy } from "./components/Deploy";
import Mint from "./components/Mint";
import { useTotalSupply } from "./hooks/useToken";
import Token from "./components/Token";

export default function App() {
  const { account } = useDojo();

  // entity id we are syncing
  const entityId = getEntityIdFromKeys([
    BigInt(account?.address ?? 0),
  ]) as Entity;

  const { total_supply } = useTotalSupply()

  return (
    <>
      <Deploy />
      <MasterAccountConnect />

      <div className="card">
        account:{account?.address.toString() ?? '?'}
      </div>

      <div className="card">
        <Mint />
        <div>
          Total Supply: {total_supply}
        </div>
        <Token token_id={total_supply} />
      </div>

    </>
  );
}
