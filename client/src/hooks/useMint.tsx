import { useCallback, useEffect, useMemo, useState } from "react";
import { useAccount } from "@starknet-react/core";
import { useDojo } from "../dojo/useDojo"
import { useConfig, useTokenContract, useTokenOwner, useTotalSupply } from "./useToken";
import { useIsCorrectChain } from "./useChain";
import { bigintEquals } from "../utils/types";
import { goToTokenPage } from "../utils/karat";

export const useMint = () => {
  const {
    setup: {
      systemCalls: { mint },
    },
    account,
  } = useDojo();

  const { contractAddress } = useTokenContract();
  const { isCoolDown, maxSupply, availableSupply } = useConfig();
  const { isConnected } = useAccount();
  const { isCorrectChain } = useIsCorrectChain()
  const { total_supply } = useTotalSupply()

  const [isMinting, setIsMinting] = useState(false);
  const [mintingTokenId, setMintingTokenId] = useState(0);

  const isAvailable = useMemo(() => (total_supply < availableSupply), [total_supply, availableSupply]);
  const isMintedOut = useMemo(() => (total_supply >= maxSupply), [total_supply, maxSupply]);

  const canMint = useMemo(() => (
    account && isConnected && isCorrectChain && contractAddress && isAvailable && !isMintedOut && !isMinting
  ), [account, isConnected, isCorrectChain, contractAddress, isMintedOut, isAvailable, isMinting]);

  const _mint = useCallback(() => {
    if (account && canMint) {
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
  }, [account, canMint, contractAddress, total_supply]);

  useEffect(() => {
    if (isMinting && total_supply >= mintingTokenId) {
      // ...supply changed, to to token!
      setIsMinting(false);
      goToTokenPage(mintingTokenId);
    }
  }, [mintingTokenId, total_supply]);

  const { ownerAddress: lastOwnerAddress } = useTokenOwner(total_supply);
  const isCoolingDown = useMemo(() => (account ? bigintEquals(lastOwnerAddress, account.address) : undefined), [account, lastOwnerAddress, total_supply])
  // const isCoolingDown = false;

  return {
    canMint,
    isMinting,
    isAvailable,
    isMintedOut,
    isCoolingDown: (isCoolingDown && isCoolDown),
    mint: (canMint ? _mint : undefined),
  }
}

