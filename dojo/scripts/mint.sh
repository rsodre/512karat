#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..
source scripts/setup.sh

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
echo "> minting..."
sozo execute katat-minter mint --calldata $TOKEN_ADDRESS --world $WORLD_ADDRESS --wait
