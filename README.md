# 512karat

## Generative Art made with Dojo

For the [ETHGlobal StarkHack](https://ethglobal.com/events/starkhack) hackaton between June 13th and June 23rd 2024.

code + art: **Roger Mataleone** ([@matalecode](https://x.com/matalecode))


## Project structure

* `/dojo`: Dojo contracts
* `/client`: Typescript Vite client
* `/draft`: Token experiments (metadata, svg)
* [p5js](https://editor.p5js.org/rsodre/sketches/Im7yQgmf5): Art playground


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

* Added [StarknetKit](https://www.starknetkit.com/) connectors with [starknet-react](https://starknet-react.com/)
* Added [semantic-ui](https://react.semantic-ui.com) + [scss](https://sass-lang.com/)
* Added [Saira](https://fonts.google.com/specimen/Saira) font from Google fonts


#### Art

* Token art drafted with [p5js](https://editor.p5js.org/rsodre/sketches/Im7yQgmf5) then ported to Cairo
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


#### Deployment steps

Steps for migrating to Sepolia (Mainnet is the same)

* Create `sepolia` profile in [`Scarb.toml`](https://github.com/rsodre/512karat/blob/main/dojo/Scarb.toml)
```
[profile.sepolia.tool.dojo.env]
rpc_url = "https://my.provider.com/starknet/sepolia/rpc"
world_address = "0x3e42a9746e6c8f868f71a4353ec5d198f0dd1af26f95bd51e2e005358ae14fd"
# account_address = "" # env: DOJO_ACCOUNT_ADDRESS
# private_key = ""     # env: DOJO_PRIVATE_KEY
```
* Build for Sepolia to generate manifests
```sh
sozo -P sepolia build
```
* Create overlay files for Sepolia
```sh
sozo -P sepolia migrate generate-overlays
```
* Cloned [`dev`](https://github.com/rsodre/512karat/blob/main/dojo/manifests/dev/base/contracts/karat_systems_minter_minter.toml) overlays to [`sepolia`](https://github.com/rsodre/512karat/blob/main/dojo/manifests/sepolia/base/contracts/karat_systems_minter_minter.toml)
* Create `.env.sepolia` containing your RPC provider, account and private key
```sh
# usage: source .env.sepolia
export STARKNET_RPC_URL=<YOUR_RPC_VERSION_0.6>
export DOJO_ACCOUNT_ADDRESS=<YOUR_ACCOUNT_ADDRESS>
export DOJO_PRIVATE_KEY=<YOUR_ACCOUNT_PRIVATE_KEY>
```
* Load `.env.sepolia`
```sh
source .env.sepolia
```
* Check migration, no errors!
```sh
sozo -P sepolia migrate plan
```
* Execute migration using the [`migrate`](https://github.com/rsodre/512karat/blob/main/dojo/migrate) script...
```sh
./migrate sepolia
```

Now we need to create a torii server to index our world...

* Install [slot](https://github.com/cartridge-gg/slot) or update it
```sh
slotup
```
* Authorize
```sh
slot auth login
```
* Create Torii service...
  * `SERVICE_NAME` can be the name of the game/dapp. Once you create it, you own that name.
  * The version is your Dojo version
  * Fill in your own World address
  * Check the contracts deployment transaction to use as starting block
  * Take a note of the endpoints after it is deployed.
```sh
slot deployments create <SERVICE_NAME> torii --version v0.7.2 --world 0x0545c8aff15426c3d43b3ba8fd45c61870b30ca4ec0bfbd69193facee4c7b97c --rpc <RPC_URL> --start-block 75600 --index-pending true
```
* If for any reasons we need to delete and recreate Torii
```sh
slot deployments delete 512karat torii
```



#### Multichain client notes

* The `migrate` script is copying manifests to `/client/src/dojo/generated/<PROFILE>`, each chain needs to use their own manifest!
* Adapted `dojoConfig` to create different setups for each chain, adding the torii endpoint.
* Moved Dojo setup to new `<DojoSetup>`, and inside `<App>`, only when user is connected, using connected chain


