import { useMint } from "../hooks/useMint";

export default function Mint() {
  const { mint } = useMint()
  return (
    <>
      <button disabled={!mint} onClick={() => mint?.()}>Mint</button>
    </>
  );
}
