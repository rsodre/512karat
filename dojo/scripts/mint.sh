#!/bin/bash
set -euo pipefail
source scripts/setup.sh

# move down to /dojo
pushd $(dirname "$0")/..

# sozo execute --world <WORLD_ADDRESS> <CONTRACT> <ENTRYPOINT>
echo "> minting..."
sozo execute katat-minter mint --calldata $TOKEN_ADDRESS --world $WORLD_ADDRESS --wait
