import { useDojo } from "../dojo/useDojo";
import { useTokenContract } from "../hooks/useToken";

export default function Mint() {
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
    }
  }

  return (
    <>
      <button disabled={!account} onClick={() => _mint()}>Mint</button>
    </>
  );
}
