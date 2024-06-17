import { AccountInterface } from "starknet";
import {
  getEvents,
  setComponentsFromEvents,
} from "@dojoengine/utils";
import { ContractComponents } from "./generated/contractComponents";
import type { IWorld } from "./generated/generated";

export type SystemCalls = ReturnType<typeof createSystemCalls>;

export function createSystemCalls(
  { client }: { client: IWorld },
  contractComponents: ContractComponents,
  // { Config, Seed }: ClientComponents
) {
  const mint = async (account: AccountInterface) => {

    try {
      const { transaction_hash } = await client.minter.mint({ account });

      setComponentsFromEvents(
        contractComponents,
        getEvents(
          await account.waitForTransaction(transaction_hash, {
            retryInterval: 100,
          })
        )
      );
    } catch (e) {
      console.error(`MINT ERROR:`, e);
    }
  };

  return {
    mint,
  };
}
