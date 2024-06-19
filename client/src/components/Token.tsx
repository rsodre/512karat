import { BigNumberish } from "starknet";
import { useTokenUri } from "../hooks/useTokenUri";

export default function Token({
  token_id,
}: {
  token_id: BigNumberish
}) {
  const { uri } = useTokenUri(token_id);
  return (
    <>
    [{uri}]
      {/* <button disabled={!mint} onClick={() => mint?.()}>Mint</button> */}
    </>
  );
}
