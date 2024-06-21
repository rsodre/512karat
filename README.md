# 512karat

## Generative Art made with Dojo

For the [ETHGlobal StarkHack](https://ethglobal.com/events/starkhack) hackaton between June 13th and June 23rd 2024.

code + art: **Roger Mataleone** ([@matalecode](https://x.com/matalecode))


## Project structure

* `/dojo`: Dojo contracts
* `/client`: Typescript Vite client
* `/draft`: Token experiments (metadata, svg)
* Token art developed at [p5js.org](https://editor.p5js.org/rsodre/sketches/Im7yQgmf5) then ported to Cairo.

## Resources and History

This project sarted from scratch, using a few open source boilerplates, mainly from [Dojo](https://www.dojoengine.org/), [Origami](https://book.dojoengine.org/toolchain/origami) and [Pistols at 10 Blocks](https://pistols.underware.gg/).

* Dojo [starter](https://book.dojoengine.org/tutorial/dojo-starter) template
```sh
sozo init dojo
```
* Cloned [origami](https://github.com/dojoengine/origami/tree/v0.7.2) [preset](https://github.com/dojoengine/origami/blob/v0.7.2/token/src/presets/erc721/enumerable_mintable_burnable.cairo): `enumerable_mintable_burnable.cairo` as the erc-721 token contract starting point
* Cloned origami [component](https://github.com/dojoengine/origami/blob/v0.7.2/token/src/components/token/erc721/erc721_metadata.cairo): `erc721_metadata.cairo` so we can customize `token_uri()`
* Generated overlay files for `dojo_init()`
```sh
sozo migrate --generate-overlays
```
* Cloned [ConfigManager](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/dojo/src/models/config.cairo) from Pistols (originally from [Dope Wars](https://github.com/cartridge-gg/dopewars))
* Cloned [migrate script](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/dojo/migrate), [cairo hasher](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/dojo/src/utils/hash.cairo), [cairo seeder](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/dojo/src/systems/seeder.cairo), [styles](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/client/styles/styles.scss), [misc utils](https://github.com/underware-gg/pistols/tree/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/client/src/lib/utils) and [cosmetic components](https://github.com/underware-gg/pistols/blob/b4010c442260cd2ca574fc49d7f2fbdc748cf51f/client/src/lib/ui) from [Pistols](https://github.com/underware-gg/pistols).
* Cloned base64 [encoder](https://github.com/BibliothecaDAO/codename-bobby-realms/blob/main/contracts/src/utils/encoding.cairo) from [Blobert](https://blobert.realms.world/)
* Cloned [starknet-react-app](https://github.com/dojoengine/dojo.js/tree/main/examples/react/starknet-react-app) example from [dojo.js](https://github.com/dojoengine/dojo.js)
* Added [semantic-ui](https://react.semantic-ui.com) + [scss](https://sass-lang.com/)
* Added [Saira](https://fonts.google.com/specimen/Saira) font from Google fonts

