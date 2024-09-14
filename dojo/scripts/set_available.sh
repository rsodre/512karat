#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..
source scripts/setup.sh

export AMOUNT=$2

if [ "$AMOUNT" == "" ]; then
  echo "usage: $0 <PROFILE> <ACCOUNT>"
  exit 1
fi

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
echo "> new available supply: $AMOUNT"
sozo execute katat-minter set_available --calldata $TOKEN_ADDRESS,$AMOUNT --world $WORLD_ADDRESS --wait
