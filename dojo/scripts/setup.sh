# Profile
if [ $# -ge 1 ]; then
  export PROFILE=$1
else
  export PROFILE="dev"
fi
export DOJO_PROFILE_FILE="dojo_$PROFILE.toml"

if ! [ -x "$(command -v toml)" ]; then
  echo 'Error: toml not instlaled! Instal with: cargo install toml-cli'
  exit 1
fi

get_profile_env () {
  local ENV_NAME=$1
  local RESULT=$(toml get $DOJO_PROFILE_FILE --raw env.$ENV_NAME)
  if [[ -z "$RESULT" ]]; then
    >&2 echo "get_profile_env($ENV_NAME) not found! 👎"
  fi
  echo $RESULT
}

#-----------------
# env setup
#
export GAME_SLUG="pistols"
export PROJECT_NAME=$(toml get $DOJO_PROFILE_FILE --raw world.name)
export WORLD_ADDRESS=$(get_profile_env "world_address")
export ACCOUNT_ADDRESS=${DOJO_ACCOUNT_ADDRESS:-$(get_profile_env "account_address")}
export MANIFEST_FILE_PATH="./manifests/$PROFILE/deployment/manifest.json"
export RPC_URL=${STARKNET_RPC_URL:-$(get_profile_env "rpc_url")}

export TOKEN_ADDRESS=$(cat $MANIFEST_FILE_PATH | jq -r '.contracts[] | select(.tag == "karat-karat_token" ).address')
export MINTER_ADDRESS=$(cat $MANIFEST_FILE_PATH | jq -r '.contracts[] | select(.tag == "karat-minter" ).address')

echo "------------------------------------------------------------------------------"
echo "PROFILE: $PROFILE"
echo "PROJECT: $PROJECT_NAME"
echo "RPC_URL: $RPC_URL"
echo "MANIFEST_FILE_PATH: $MANIFEST_FILE_PATH"
echo "WORLD_ADDRESS: $WORLD_ADDRESS"
echo "TOKEN_ADDRESS: $TOKEN_ADDRESS"
echo "MINTER_ADDRESS: $MINTER_ADDRESS"
echo "------------------------------------------------------------------------------"

if [[ "$RPC_URL" == "" ]]; then
  echo "! Missing RPC_URL 👎"
  exit 1
fi

if [[ "$WORLD_ADDRESS" != "0x"* ]]; then
  echo "! Missing WORLD_ADDRESS 👎"
  exit 1
fi

