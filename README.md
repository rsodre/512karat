# 512 KARAT

## Generative Art made with Dojo

Finalist [project](https://ethglobal.com/showcase/512-karat-3sq17) of the [ETHGlobal StarkHack](https://ethglobal.com/events/starkhack), built from June 13th-23rd 2024. The original submission is on the [stark_hack](https://github.com/rsodre/512karat/tree/stark_hack) tag.

code + art: **Roger Mataleone** ([@matalecode](https://x.com/matalecode))


## Mainnet Minting

* Phase 1 (128 Karats): TBD
* Phase 2 (128 Karats): TBD
* Phase 3 (128 Karats): TBD
* Phase 4 (128 Karats): TBD


## Project structure

* `/dojo`: Dojo contracts
* `/client`: Typescript Vite client
* `/draft`: Token experiments (metadata, svg)
* [p5js](https://editor.p5js.org/rsodre/sketches/Im7yQgmf5): Art playground


## Sepolia / Mainnet Deployment

This is a **generic guide** to deploy a Dojo world to Sepolia.
The steps for Mainnet are exactly the same, just replace the chain name and ID when necessary.


### Setup

* You need a [Starknet RPC Provider](https://www.starknet.io/fullnodes-rpc-services/) to deploy contracts on-chain. After you get yours, check if it works and is on the chain you want to deploy (`SN_SEPOLIA` or `SN_MAINNET`)

```sh
# run this...
curl --location '<RPC_PROVIDER_URL>' \
--header 'Content-Type: application/json' \
--data '{"id": 0,"jsonrpc": "2.0","method": "starknet_chainId","params": {}}'

# you should get an output like this...
{"jsonrpc":"2.0","result":"0x534e5f5345504f4c4941","id":0}

# now paste the hex result part on this command... 
echo 0x534e5f5345504f4c4941 | xxd -r -p

# which !must! output SN_SEPOLIA or SN_MAINNET
SN_SEPOLIA
```

* Declare the `sepolia` profile in [`Scarb.toml`](https://github.com/rsodre/512karat/blob/main/dojo/Scarb.toml)

```toml
[profile.sepolia]
```

* Create the [`dojo_sepolia.toml`](https://github.com/rsodre/512karat/blob/main/dojo/dojo_sepolia.toml) dojo config file, with the same contents of [`dojo_dev.toml`](https://github.com/rsodre/512karat/blob/main/dojo/dojo_dev.toml), except for `[env]`, in which we're going to expose the `world_address` only:

```toml
[env]
# rpc_url = ""         # env: STARKNET_RPC_URL
# account_address = "" # env: DOJO_ACCOUNT_ADDRESS
# private_key = ""     # env: DOJO_PRIVATE_KEY
world_address = "0x30ce813d2c4d55298764d676bbc1f37fb8b6337e29337692c7133f52d106878"
```

* Clone the [`dev`](https://github.com/rsodre/512karat/blob/main/dojo/overlays/dev/) overlays to [`sepolia`](https://github.com/rsodre/512karat/blob/main/dojo/overlays/sepolia/)

* Create `.env.sepolia` containing your RPC provider, account and private key. Make sure that account is deployed and has some [ETH](https://starknet-faucet.vercel.app) in it (0.001 is more than enough).

```sh
# usage: source .env.sepolia
export STARKNET_RPC_URL=<RPC_PROVIDER_URL>
export DOJO_ACCOUNT_ADDRESS=<YOUR_ACCOUNT_ADDRESS>
export DOJO_PRIVATE_KEY=<YOUR_ACCOUNT_PRIVATE_KEY>
```



### Deployment

* Load `.env.sepolia`.

**IF FOR ANY REASON YOU ABORT THE DEPLOYMENT, JUMP TO THE CLEANUP STEP TO UNDO THIS**

```sh
cd dojo
source .env.sepolia
```

* Build and check for errors. If the `migrate plan` command raises any errors, fix and try again before continuing.

```sh
cd dojo
sozo -P sepolia clean
sozo -P sepolia build
sozo -P sepolia migrate plan
```

* Execute migration using the [`migrate`](https://github.com/rsodre/512karat/blob/main/dojo/migrate) script...

```sh
cd dojo
./migrate sepolia
```

Your world is deployed!


### Cleanup env !!!!!!!

Clear env after all is done...

**THIS IS VERY IMPORTANT, OR YOUR NEXT LOCAL DEPLOYMENT MAY GO TO SEPOLIA OR MAINNET!**

```sh
cd dojo
source .env.clear
```



### Torii Indexer

Now, if you're building a Dojo client, you will need a Torii service to index our world...

* Install [slot](https://github.com/cartridge-gg/slot) or update it

```sh
slotup
```

* Authorize

```sh
slot auth login
```

* Find your world starting block. Replace your world address on the following link, clink on **Deployed At Transaction Hash** and write down the **Block Number**. (it may take a while before the link works if you use it right after deployment)

[https://sepolia.starkscan.co/contract/0x04c0970c9f52045ef8eeedd1e11265ebb69ed90fce58c96ad103aecf7f91302a](https://sepolia.starkscan.co/contract/0x04c0970c9f52045ef8eeedd1e11265ebb69ed90fce58c96ad103aecf7f91302a)

* Create Torii service with this command, replacing...
  * `SERVICE_NAME` can be the name of the game/dapp. Once you create it, you own that name.
  * `DOJO_VERSION`: your Dojo version (ex: `v1.0.0-alpha.9`)
  * `WORLD_ADDRESS`: from your Dojo config file [`dojo_sepolia.toml`](https://github.com/rsodre/512karat/blob/main/dojo/dojo_sepolia.toml)
  * `RPC_URL`: your RPC provider url
  * `STARTING_BLOCK`: the deployment transaction block we just found before
  * Take a note of the endpoints after it is deployed...

```sh
slot deployments create <SERVICE_NAME> torii --version <DOJO_VERSION> --world <WORLD_ADDRESS> --rpc <RPC_URL> --start-block <STARTING_BLOCK> --index-pending true
```

* slot will output something like this. Save it for later, you will need the endpoints on your client.

```
Deployment success 🚀

Configuration:
  World: 0x4c0970c9f52045ef8eeedd1e11265ebb69ed90fce58c96ad103aecf7f91302a
  RPC: <RPC_PROVIDER_URL>
  Start Block: 155777
  Index Pending: false

Endpoints:
  GRAPHQL: https://api.cartridge.gg/x/512karat-sepolia/torii/graphql
  GRPC: https://api.cartridge.gg/x/512karat-sepolia/torii

Stream logs with `slot deployments logs 512karat-sepolia torii -f`
```


* If for any reasons we need to recreate Torii, we can just delete it and run the create command again. This is safe, all your data is on-chain.

```sh
slot deployments delete <SERVICE_NAME> torii
```


### Some notes on the client side

* The `migrate` script is copying manifests to `/client/src/dojo/generated/<PROFILE>`, each chain needs to use their own manifest!

* Take a look at [`dojoConfig.ts`](/client/src/dojo/dojoConfig.ts) to create different setups for each chain, adding the torii endpoint.

* The client needs the env variable `VITE_PUBLIC_CHAIN_ID` to be set to your chain id. Configure on your sever and add it to your `.env` to access your deployment localy:

```
VITE_PUBLIC_CHAIN_ID=SN_SEPOLIA
```




## Resources and Process

This project sarted from scratch for [StarkHack 2024](https://ethglobal.com/events/starkhack), using a few open source boilerplates, mainly from [Dojo](https://www.dojoengine.org/), [Origami](https://book.dojoengine.org/toolchain/origami) and [Pistols at 10 Blocks](https://pistols.underware.gg/).

The original submission, containing the full process of how it was built in June 2024 is on the [stark_hack](https://github.com/rsodre/512karat/tree/stark_hack) tag (**outdated!**).
