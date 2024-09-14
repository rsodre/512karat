import { useEffect } from "react";
import { Button } from "semantic-ui-react";
// import { useDebug } from "../hooks/useDebug";
import { useMint } from "../hooks/useMint";
import { useOpener } from "../hooks/useOpener";
import MintModal from "./MintModal";
import { useChainSwitchCallback } from "../hooks/useChain";

export default function MintButton() {
  // const { isDebug } = useDebug();
  const { canMint, mint, isMinting, isCoolingDown, isAvailable, isMintedOut } = useMint()

  const opener = useOpener()
  useEffect(() => { opener.open(isMinting) }, [isMinting])

  const { switch_starknet_chain, switchMessage } = useChainSwitchCallback()

  const disabled = (!canMint || isCoolingDown)
  const label =
    isMintedOut ? 'Minted Out'
      : !isAvailable ? 'Unavailable'
        : isCoolingDown ? 'Cooling Down'
          : isMinting ? 'Minting...'
            : 'Mint'

  if (switch_starknet_chain) {
    return (
      <Button onClick={() => switch_starknet_chain()}>
        {switchMessage}
      </Button>
    )
  }

  return (
    <>
      <Button disabled={disabled} onClick={() => mint?.()}>
        {label}
      </Button>
      <MintModal opener={opener} isMinting={isMinting} />
    </>
  );
}
