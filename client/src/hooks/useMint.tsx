import { useDojo } from "../dojo/useDojo"
import { useTokenContract } from "./useToken";

export const useMint = () => {
  const {
    setup: {
      systemCalls: { mint },
    },
    account,
  } = useDojo();

  const { contractAddress } = useTokenContract();

  const _mint = () => {
    if (account && contractAddress) {
      mint(account, contractAddress);
    } else {
      return null
    }
  }
  return {
    mint: _mint
  }
}

