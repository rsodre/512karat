import { Button } from "semantic-ui-react";
import { useMint } from "../hooks/useMint";
import { useDebug } from "../hooks/useDebug";

export default function Mint() {
  const { isDebug } = useDebug();
  const { canMint, isCoolingDown, mint } = useMint()
  return (
    <>
      <Button disabled={!canMint && !isDebug} onClick={() => mint?.()}>{isCoolingDown ? 'Cooling down' : 'Mint'}</Button>
    </>
  );
}
