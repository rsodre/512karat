import { BigNumberish } from "starknet";
import { useTokenUri } from "../hooks/useTokenUri";

export default function Token({
  token_id,
}: {
  token_id: BigNumberish
}) {
  const { name, description, image } = useTokenUri(token_id);
  return (
    <>
      <h5>{name}</h5>
      <h5>{description}</h5>
      <img src={image} />
      {/* <button disabled={!mint} onClick={() => mint?.()}>Mint</button> */}
    </>
  );
}
