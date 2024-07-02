import { useEffect } from "react";
import { Button } from "semantic-ui-react";
// import { useDebug } from "../hooks/useDebug";
import { useConfig } from "../hooks/useToken";
import { useMint } from "../hooks/useMint";
import { useOpener } from "../hooks/useOpener";
import MintingModal from "./MintingModal";

export default function Mint() {
  // const { isDebug } = useDebug();
  const { isClosed } = useConfig();
  const { canMint, mint, isMinting, isCoolingDown } = useMint()
  
  const opener = useOpener()
  useEffect(() => { opener.open(isMinting) }, [isMinting])

  const disabled = (!canMint || isCoolingDown || isClosed)
  const label =
    isClosed ? 'Minting Closed'
      : isCoolingDown ? 'Cooling Down'
        : isMinting ? 'Minting...'
          : 'Mint'

  return (
    <>
      <Button disabled={disabled} onClick={() => mint?.()}>
        {label}
      </Button>
      <MintingModal opener={opener} isMinting={isMinting} />
    </>
  );
}
