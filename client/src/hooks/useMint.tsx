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
  const { totalSupply } = useTotalSupply()

  const [isMinting, setIsMinting] = useState(false);
  const [mintingTokenId, setMintingTokenId] = useState(0);

  const isAvailable = useMemo(() => (totalSupply < availableSupply), [totalSupply, availableSupply]);
  const isMintedOut = useMemo(() => (totalSupply >= maxSupply), [totalSupply, maxSupply]);

  const canMint = useMemo(() => (
    account && isConnected && isCorrectChain && contractAddress && isAvailable && !isMintedOut && !isMinting
  ), [account, isConnected, isCorrectChain, contractAddress, isMintedOut, isAvailable, isMinting]);

  const _mint = useCallback(() => {
    if (account && canMint) {
      setIsMinting(true);
      setMintingTokenId(totalSupply + 1);
      mint(account, contractAddress).then((v) => {
        // wait supply to change...
      }).catch((e) => {
        console.error(`mint error:`, e);
        setMintingTokenId(0);
        setIsMinting(false);
      });
    }
  }, [account, canMint, contractAddress, totalSupply]);

  useEffect(() => {
    if (isMinting && totalSupply >= mintingTokenId) {
      // ...supply changed, to to token!
      setIsMinting(false);
      goToTokenPage(mintingTokenId);
    }
  }, [mintingTokenId, totalSupply]);

  const { ownerAddress: lastOwnerAddress } = useTokenOwner(totalSupply);
  const isCoolingDown = useMemo(() => (account ? bigintEquals(lastOwnerAddress, account.address) : undefined), [account, lastOwnerAddress, totalSupply])
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

