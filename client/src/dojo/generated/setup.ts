import { getSyncEntities } from "@dojoengine/state";
import {
  DojoConfig,
  DojoProvider,
  createModelTypedData,
} from "@dojoengine/core";
import * as torii from "@dojoengine/torii-client";
import { createClientComponents } from "../createClientComponents";
import { createSystemCalls } from "../createSystemCalls";
import { defineContractComponents } from "./contractComponents";
import { world } from "./world";
import { setupWorld } from "./setupWorld";
import { TypedData, WeierstrassSignatureType } from "starknet";

export type SetupResult = Awaited<ReturnType<typeof setup>>;

export async function setup({ ...config }: DojoConfig) {
  // torii client
  console.log(`>> SETUP config:`, config)
  const toriiClient = await torii.createClient({
    rpcUrl: config.rpcUrl,
    toriiUrl: config.toriiUrl,
    relayUrl: "",
    worldAddress: config.manifest.world.address || "",
  });

  // create contract components
  const contractComponents = defineContractComponents(world);

  // create client components
  const clientComponents = createClientComponents({ contractComponents });

  // fetch all existing entities from torii
  const sync = await getSyncEntities(toriiClient, contractComponents as any, []);
  console.log(`>> SYNC finished:`, clientComponents)

  // create dojo provider
  const dojoProvider = new DojoProvider(config.manifest, config.rpcUrl);

  // setup world
  const client = await setupWorld(dojoProvider);

  return {
    client,
    clientComponents,
    contractComponents,
    systemCalls: createSystemCalls(
      { client },
      contractComponents,
      clientComponents,
    ),
    // publish: (typedData: string, signature: WeierstrassSignatureType) => {
    //   toriiClient.publishMessage(typedData, {
    //     r: signature.r.toString(),
    //     s: signature.s.toString(),
    //   });
    // },
    config,
    dojoProvider,
    manifest: config.manifest,
    // burnerManager,
    sync,
  };
}
