import { useEffect, useMemo, useState } from "react";
import { useAccount } from "@starknet-react/core";
import { useDojo } from "../dojo/useDojo"
import { useTokenContract, useTokenOwner, useTotalSupply } from "./useToken";
import { bigintEquals } from "../utils/types";
import { goToTokenPage } from "../components/Navigation";

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

  const [isMinting, setIsMinting] = useState(false);
  const [mintingTokenId, setMintingTokenId] = useState(0);
  const _mint = () => {
    if (account && !isMinting) {
      setIsMinting(true);
      setMintingTokenId(total_supply + 1);
      mint(account, contractAddress).then((v) => {
        // wait supply to change...
      }).catch((e) => {
        console.error(`mint error:`, e);
        setMintingTokenId(0);
        setIsMinting(false);
      });
    }
  }

  useEffect(() => {
    if (isMinting && total_supply >= mintingTokenId) {
      // ...supply changed, to to token!
      setIsMinting(false);
      goToTokenPage(mintingTokenId, total_supply);
    }
  }, [mintingTokenId, total_supply]);

  const canMint = useMemo(() => (account && isConnected && contractAddress && !isMinting), [isConnected, account, contractAddress, isMinting]);

  const { ownerAddress: lastOwnerAddress } = useTokenOwner(total_supply);
  const isCoolingDown = useMemo(() => (account && canMint && bigintEquals(lastOwnerAddress, account.address)), [account, canMint, lastOwnerAddress])
  // const isCoolingDown = false;

  return {
    canMint: (canMint && !isCoolingDown),
    isMinting,
    isCoolingDown,
    mint: _mint,
  }
}

