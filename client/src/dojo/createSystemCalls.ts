import { AccountInterface, BigNumberish } from "starknet";
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
  const mint = async (account: AccountInterface, contract_address: BigNumberish) => {
    try {
      const { transaction_hash } = await client.minter.mint({ account, contract_address });
      // setComponentsFromEvents(
      //   contractComponents,
      //   getEvents(
      //     await account.waitForTransaction(transaction_hash, {
      //       retryInterval: 100,
      //     })
      //   )
      // );
    } catch (e) {
      console.error(`MINT ERROR:`, e);
    }
  };

  const token_uri = async (token_id: BigNumberish): Promise<string | null> => {
    try {
      const uri = await client.karat_token.token_uri({ token_id });
      return uri as string ?? null
    } catch (e) {
      console.error(`TOKEN_URI ERROR:`, e);
      return null
    }
  };

  return {
    mint,
    token_uri,
  };
}
