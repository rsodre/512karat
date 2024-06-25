import { Button } from "semantic-ui-react";
import { useMint } from "../hooks/useMint";
import { useDebug } from "../hooks/useDebug";

export default function Mint() {
  const { isDebug } = useDebug();
  const { canMint, mint, isMinting, isCoolingDown } = useMint()
  return (
    <>
      <Button disabled={!canMint && !isDebug} onClick={() => mint?.()}>
        {isMinting ? 'Minting...' : isCoolingDown ? 'Cooling Down' : 'Mint'}
      </Button>
    </>
  );
}
