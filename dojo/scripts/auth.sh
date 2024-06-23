#!/bin/bash
set -euo pipefail
pushd $(dirname "$0")/..

# Profile
if [ $# -ge 1 ]; then
  export PROFILE=$1
else
  export PROFILE="dev"
fi

if ! [ -x "$(command -v toml)" ]; then
  echo 'Error: toml not instlaled! Instal with: cargo install toml-cli'
  exit 1
fi
if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq not instlaled! Instal with: brew install jq'
  exit 1
fi

export MANIFEST_FILE_PATH="./manifests/$PROFILE/manifest.json"
export WORLD_ADDRESS=$(toml get Scarb.toml --raw profile.$PROFILE.tool.dojo.env.world_address)
export TOKEN_ADDRESS=$(cat $MANIFEST_FILE_PATH | jq -r '.contracts[] | select(.name == "karat::systems::karat_token::karat_token" ).address')
export MINTER_ADDRESS=$(cat $MANIFEST_FILE_PATH | jq -r '.contracts[] | select(.name == "karat::systems::minter::minter" ).address')
# use $DOJO_ACCOUNT_ADDRESS else read from profile
export ACCOUNT_ADDRESS=${DOJO_ACCOUNT_ADDRESS:-$(toml get Scarb.toml --raw profile.$PROFILE.tool.dojo.env.account_address)}

echo "------------------------------------------------------------------------------"
echo "Profile     : $PROFILE"
echo "Manifest    : $MANIFEST_FILE_PATH"
echo "Account     : $ACCOUNT_ADDRESS"
echo "World       : $WORLD_ADDRESS"
echo "::karat     : $TOKEN_ADDRESS"
echo "::minter    : $MINTER_ADDRESS"
echo "------------------------------------------------------------------------------"

if [[
  -z "$PROFILE" ||
  -z "$MANIFEST_FILE_PATH" ||
  "$ACCOUNT_ADDRESS" != "0x"* || # for testing profile
  "$WORLD_ADDRESS" != "0x"* ||
  "$TOKEN_ADDRESS" != "0x"* ||
  "$MINTER_ADDRESS" != "0x"*
]]; then
  echo "! Missing data 👎"
  exit 1
fi

# auth ref: https://book.dojoengine.org/toolchain/sozo/world-commands/auth
echo "- Token auth..."
sozo -P $PROFILE auth grant --world $WORLD_ADDRESS --wait writer \
  InitializableModel,$TOKEN_ADDRESS \
  ERC721MetaModel,$TOKEN_ADDRESS \
  ERC721OperatorApprovalModel,$TOKEN_ADDRESS \
  ERC721TokenApprovalModel,$TOKEN_ADDRESS \
  ERC721BalanceModel,$TOKEN_ADDRESS \
  ERC721EnumerableIndexModel,$TOKEN_ADDRESS \
  ERC721EnumerableOwnerIndexModel,$TOKEN_ADDRESS \
  ERC721EnumerableOwnerTokenModel,$TOKEN_ADDRESS \
  ERC721EnumerableTokenModel,$TOKEN_ADDRESS \
  ERC721EnumerableTotalModel,$TOKEN_ADDRESS \
  ERC721OwnerModel,$TOKEN_ADDRESS \

echo "- Minter auth..."
sozo -P $PROFILE auth grant --world $WORLD_ADDRESS --wait writer \
  Config,$MINTER_ADDRESS \
  Seed,$MINTER_ADDRESS \

echo "--- Auth ok! 👍"
