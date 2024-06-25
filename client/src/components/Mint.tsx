import { useEffect } from "react";
import { Button } from "semantic-ui-react";
import { useMint } from "../hooks/useMint";
import { useDebug } from "../hooks/useDebug";
import { useOpener } from "../hooks/useOpener";
import MintingModal from "./MintingModal";

export default function Mint() {
  const { isDebug } = useDebug();
  const { canMint, mint, isMinting, isCoolingDown } = useMint()
  const opener = useOpener()
  useEffect(() => { opener.open(isMinting) }, [isMinting])
  return (
    <>
      <Button disabled={!canMint && !isDebug} onClick={() => mint?.()}>
        {isMinting ? 'Minting...' : isCoolingDown ? 'Cooling Down' : 'Mint'}
      </Button>
      <MintingModal opener={opener} isMinting={isMinting} />
    </>
  );
}
