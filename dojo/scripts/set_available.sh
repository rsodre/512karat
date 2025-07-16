#!/bin/bash
set -euo pipefail
source scripts/setup.sh

if [ $# -ge 2 ]; then
  export AMOUNT=$2
else
  # export PROFILE="dev"
  echo "usage: $0 <PROFILE> <AMOUNT>"
  exit 1
fi

# move down to /dojo
pushd $(dirname "$0")/..

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
echo "> new available supply: $AMOUNT"
sozo execute karat-minter --world $WORLD_ADDRESS --wait set_available $TOKEN_ADDRESS,$AMOUNT
