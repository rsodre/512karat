#!/bin/bash
set -euo pipefail
source scripts/setup.sh

# if [ $# -ge 2 ]; then
#   export TREASURY_ADDRESS=$2
# else
#   # export PROFILE="dev"
#   echo "usage: $0 <PROFILE> <TREASURY_ADDRESS>"
#   exit 1
# fi

if [[ "$PROFILE" == "sepolia" ]]; then
  export TREASURY_ADDRESS=0x020dD2C29473df564F9735B7c16063Eb3B7A4A3bd70a7986526636Fe33E8227d
elif [[ "$PROFILE" == "mainnet" ]]; then
  export TREASURY_ADDRESS=0x015aF5935c1CBd913B069973aB162c364a03eB6e3Ea311d50a06A8C2bA060AC8
else
  echo "! Missing TREASURY_ADDRESS 👎"
  exit 1
fi

# STRK address is the same in all networks
# https://docs.starknet.io/resources/chain-info/
export STRK_ADDRESS=0x04718f5a0fc34cc1af16a1cdee98ffb20c31f5cd61d6ab07201858f4287c938d

# move down to /dojo
pushd $(dirname "$0")/..

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
echo "> karat_init()"
sozo execute karat-karat_token karat_init --world $WORLD_ADDRESS --wait
echo "> set_royalty()"
sozo execute karat-minter set_royalty --calldata $TOKEN_ADDRESS,$TREASURY_ADDRESS,250 --world $WORLD_ADDRESS --wait
echo "> set_purchase_price()"
sozo execute karat-minter set_purchase_price --calldata $TOKEN_ADDRESS,$STRK_ADDRESS,100 --world $WORLD_ADDRESS --wait

sozo -P $PROFILE model get karat-Config $TOKEN_ADDRESS
sozo -P $PROFILE call karat-karat_token supports_interface --calldata 0x2d3414e45a8700c29f119a54b9f11dca0e29e06ddcb214018fc37340e165ed6 --world $WORLD_ADDRESS
sozo -P $PROFILE call karat-karat_token supports_interface --calldata 0x12c8405df0790491b695f1b5bf7d22c855ae0b1745deaa890f763bb9d0a06ca --world $WORLD_ADDRESS
sozo -P $PROFILE call karat-minter get_price --calldata $TOKEN_ADDRESS --world $WORLD_ADDRESS
# sozo -P $PROFILE call karat-karat_token contract_uri
