import { BigNumberish } from "starknet";
import { useTokenUri } from "../hooks/useTokenUri";
import { useTokenOwner } from "../hooks/useToken";
import { AddressShort } from "./AddressShort";

export default function Token({
  token_id,
}: {
  token_id: BigNumberish
}) {
  const { name, description, image } = useTokenUri(token_id);
  const { ownerAddress } = useTokenOwner(token_id);

  return (
    <>
      <img src={image} />
      <h5>{name}</h5>
      Owned by <AddressShort address={ownerAddress ?? 0} />
      {/* <h5>{description}</h5> */}

    </>
  );
}
