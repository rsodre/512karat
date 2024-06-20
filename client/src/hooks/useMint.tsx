import { useAccount } from "@starknet-react/core";
import { useDojo } from "../dojo/useDojo"
import { useTokenContract, useTokenOwner, useTotalSupply } from "./useToken";
import { useMemo } from "react";
import { bigintEquals, bigintToHex } from "../utils/types";

export const useMint = () => {
  const {
    setup: {
      systemCalls: { mint },
    },
    account,
  } = useDojo();

  const { contractAddress } = useTokenContract();
  const { isConnected } = useAccount();

  const { total_supply } = useTotalSupply()
  const { ownerAddress: lastOwnerAddress } = useTokenOwner(total_supply);

  const canMint = useMemo(() => (account && isConnected && contractAddress), [isConnected, account, contractAddress]);
  const isCoolingDown = useMemo(() => (account && canMint && bigintEquals(lastOwnerAddress, account.address)), [account, canMint, lastOwnerAddress])
  console.log(isCoolingDown, bigintToHex(lastOwnerAddress), account?.address)

  const _mint = () => {
    if (account && canMint) {
      mint(account, contractAddress);
    }
  }

  return {
    canMint: (canMint && !isCoolingDown),
    isCoolingDown,
    mint: _mint,
  }
}

