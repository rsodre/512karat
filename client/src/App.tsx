import { useEffect, useState } from "react";
import { useComponentValue } from "@dojoengine/react";
import { Entity } from "@dojoengine/recs";
import "./App.css";
import { Direction } from "./utils";
import { getEntityIdFromKeys } from "@dojoengine/utils";
import { useDojo } from "./dojo/useDojo";
import MasterAccountConnect from "./components/MasterWallet";
import { Deploy } from "./components/Deploy";

function App() {
  const {
    setup: {
      systemCalls: { mint },
      clientComponents: { Config, Seed },
    },
    account,
  } = useDojo();

  console.log(account);

  // entity id we are syncing
  const entityId = getEntityIdFromKeys([
    BigInt(account?.address ?? 0),
  ]) as Entity;


  return (
    <>
      <Deploy />
      <MasterAccountConnect />
      <div className="card">
        account:{account?.address.toString() ?? '?'}
      </div>

      <div className="card">
        <button disabled={!account} onClick={() => { if (account) mint(account) }}>Mint</button>
        <div>
          Total Supply: ?
        </div>
      </div>

    </>
  );
}

export default App;
