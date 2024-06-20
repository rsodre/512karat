import { Button } from "semantic-ui-react";
import { useMint } from "../hooks/useMint";

export default function Mint() {
  const { canMint, isCoolingDown, mint } = useMint()
  return (
    <>
      <Button disabled={!canMint} onClick={() => mint?.()}>{isCoolingDown ? 'Cooling down' : 'Mint'}</Button>
    </>
  );
}
