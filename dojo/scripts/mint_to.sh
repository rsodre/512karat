#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..
source scripts/setup.sh

export RECIPIENT_ADDRESS=$2

if [ "$RECIPIENT_ADDRESS" == "" ]; then
  echo "usage: $0 <PROFILE> <ACCOUNT>"
  exit 1
fi

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
echo "> minting to: $RECIPIENT_ADDRESS"
sozo execute katat-minter mint_to --calldata $TOKEN_ADDRESS,$RECIPIENT_ADDRESS --world $WORLD_ADDRESS --wait
