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
sozo execute karat-minter --world $WORLD_ADDRESS --wait set_purchase_price $TOKEN_ADDRESS,$STRK_ADDRESS,1
