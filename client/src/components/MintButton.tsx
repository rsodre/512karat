import { useEffect } from "react";
import { Button } from "semantic-ui-react";
// import { useDebug } from "../hooks/useDebug";
import { useConfig } from "../hooks/useToken";
import { useMint } from "../hooks/useMint";
import { useOpener } from "../hooks/useOpener";
import MintModal from "./MintModal";
import { useChainSwitchCallback } from "../hooks/useChain";

export default function MintButton() {
  // const { isDebug } = useDebug();
  const { isClosed } = useConfig();
  const { canMint, mint, isMinting, isCoolingDown } = useMint()
  
  const opener = useOpener()
  useEffect(() => { opener.open(isMinting) }, [isMinting])

  const { switch_starknet_chain, switchMessage } = useChainSwitchCallback()

  const disabled = (!canMint || isCoolingDown || isClosed)
  const label =
    isClosed ? 'Minting Closed'
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
