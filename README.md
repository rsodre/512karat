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
sozo migrate --generate-overlays
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