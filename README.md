# 512karat

## Generative Art made with Dojo

For the [ETHGlobal StarkHack](https://ethglobal.com/events/starkhack) hackaton between June 13th and June 23rd 2024.

code + art: **Roger Mataleone** ([@matalecode](https://x.com/matalecode))


## Minting

TBD


## Project structure

* `/dojo`: Dojo contracts
* `/client`: Typescript Vite client
* `/draft`: Token experiments (metadata, svg)
* [p5js](https://editor.p5js.org/rsodre/sketches/Im7yQgmf5): Art playground





## Sepolia / Mainnet Deployment

This is a generic guide to deploy a Dojo world to Sepolia.
The steps for Mainnet are exactly the same, just replace the chain name and ID when necessary.


### Setup

* You need a [Starknet RPC Provider](https://www.starknet.io/fullnodes-rpc-services/) to deploy contracts on-chain. So get your and check if it works and is on the chain you want to deploy (`SN_SEPOLIA` or `SN_MAINNET`)

```sh
# Run this...
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

```
[profile.sepolia]
```

* Create the [`dojo_sepolia.toml`](https://github.com/rsodre/512karat/blob/main/dojo/dojo_sepolia.toml) dojo config file, with the same contents of [`dojo_dev.toml`](https://github.com/rsodre/512karat/blob/main/dojo/dojo_dev.toml), except for `[env]`, in which we're going to expose the `world_address` only:

```
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
  RPC: https://api.cartridge.gg/rpc/starknet-sepolia
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

This project sarted from scratch, using a few open source boilerplates, mainly from [Dojo](https://www.dojoengine.org/), [Origami](https://book.dojoengine.org/toolchain/origami) and [Pistols at 10 Blocks](https://pistols.underware.gg/).


#### Smart Contracts

* Installed [Dojo](https://book.dojoengine.org/getting-started)
* Created a new project using the [dojo-starter](https://book.dojoengine.org/tutorial/dojo-starter) template:
```sh
sozo init dojo
```
* Cloned the Origami [preset](https://github.com/dojoengine/origami/blob/v0.7.2/token/src/presets/erc721/enumerable_mintable_burnable.cairo): `enumerable_mintable_burnable.cairo` as the erc-721 token contract starting point
* Cloned the Origami [component](https://github.com/dojoengine/origami/blob/v0.7.2/token/src/components/token/erc721/erc721_metadata.cairo): `erc721_metadata.cairo` so we can customize `token_uri()`
* Generated overlay files for `dojo_init()`
```sh
sozo migrate generate-overlays
```
* Edited minter overlay [file](https://github.com/rsodre/512karat/blob/main/dojo/manifests/dev/base/contracts/karat_systems_minter_minter.toml) `karat_systems_minter_minter.toml`:
```toml
name = "karat::systems::minter::minter"
reads = []
writes = ["Config", "Seed"]
computed = []
init_calldata = [
  "$contract_address:karat::systems::karat_token::karat_token",
  "512",
  "1",
]
```
* Cloned [ConfigManager](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/dojo/src/models/config.cairo) from Pistols (originally from [Dope Wars](https://github.com/cartridge-gg/dopewars))
* Cloned [migrate script](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/dojo/migrate), [cairo hasher](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/dojo/src/utils/hash.cairo), [cairo seeder](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/dojo/src/systems/seeder.cairo), [styles](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/client/styles/styles.scss), [misc utils](https://github.com/underware-gg/pistols/tree/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/client/src/lib/utils) and [cosmetic components](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/client/src/lib/ui) from [Pistols](https://github.com/underware-gg/pistols).
* Cloned base64 [encoder](https://github.com/BibliothecaDAO/codename-bobby-realms/blob/main/contracts/src/utils/encoding.cairo) from [Blobert](https://blobert.realms.world/)
* Cloned [starknet-react-app](https://github.com/dojoengine/dojo.js/tree/main/examples/react/starknet-react-app) example from [dojo.js](https://github.com/dojoengine/dojo.js)


#### Client

* Created from the [`starknet-react-app`](https://github.com/dojoengine/dojo.js/tree/main/examples/react/starknet-react-app) example
* Added [StarknetKit](https://www.starknetkit.com/) connectors with [starknet-react](https://starknet-react.com/)
* Added [semantic-ui](https://react.semantic-ui.com) + [scss](https://sass-lang.com/)
* Added [Saira](https://fonts.google.com/specimen/Saira) font from Google fonts


#### Art

* Token art drafted with [p5js](https://editor.p5js.org/rsodre/sketches/Im7yQgmf5) then ported to Cairo
  * Feel free to hit Play and try it out
  * Keys 1 to 6 will change the charset
  * Any other keys randomize a new token
* Final image is an SVG fully generated on-chain containing only text (unicode glyphs)
* When the p5js script runs, it prints the svg compatible character set ready for [Cairo](https://github.com/rsodre/512karat/blob/main/dojo/src/models/class.cairo)

```rust
Class::A => array!["&#x26AB;", "&#x26BD;", "&#x26D4;", "&#x26BE;", "&#x26AA;"].span(), 
Class::B => array!["&#x25AB;", "&#x25A2;", "&#x25A4;", "&#x25A5;", "&#x25A9;", "&#x2CBC;"].span(), 
Class::C => array!["&#x0020;", "&#x002E;", "&#x007C;", "&#x002F;", "&#x005C;", "&#x2666;"].span(), 
Class::D => array!["&#x2595;", "&#x2595;", "&#x2594;", "&#x2594;", "&#x2597;", "&#x259D;", "&#x2596;", "&#x2598;", "&#x002F;", "&#x259A;", "&#x259E;"].span(), 
Class::E => array!["&#x2B55;", "&#x0020;", "&#x0020;", "&#x002E;", "&#x25C7;", "&#x25C6;", "&#x25E2;", "&#x25E4;", "&#x25E5;", "&#x25E3;", "&#x2D54;"].span(), 
Class::L => array!["&#x0020;", "&#x005F;", "&#x002E;", "&#x26A1;", "&#x2605;", "&#x0074;", "&#x006F;", "&#x006F;", "&#x004C;", "&#x25C6;"].span(), 
```
