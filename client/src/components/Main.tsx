import { useMemo } from "react";
import { Grid, TabPane, Tab } from "semantic-ui-react";
import { useAccount } from "@starknet-react/core";
import { useTokenId } from "../hooks/useTokenId";
import { goToTokenPage } from "../utils/karat";
import Token from "./Token";
import Navigation from "./Navigation";
import { useAllTokensOfOwner, useTotalSupply } from "../hooks/useToken";
import { BigNumberish } from "starknet";

const Row = Grid.Row
const Col = Grid.Column

export default function Main() {
  const { isConnected, address } = useAccount();

  const { total_supply } = useTotalSupply();
  const { tokenIds } = useAllTokensOfOwner(address ?? 0n)

  const allTokens = useMemo(() => {
    return Array.from({ length: total_supply }, (_, i) => i + 1)
  }, [total_supply])


  const panes = useMemo(() => {
    let result = [
      {
        menuItem: 'All Tokens',
        render: () => (
          <TabPane attached={false}>
            <SingleTokenTab tokens={allTokens} />
          </TabPane>
        )
      },
    ]
    if (isConnected) {
      result.push({
        menuItem: 'Collected',
        render: () => (
          <TabPane attached={false}>
            <SingleTokenTab tokens={tokenIds} />
          </TabPane>
        )
      })
    }
    return result
  }, [isConnected])

  return (
    <>
      <Tab menu={{ secondary: true, pointing: true, attached: true }} panes={panes} />
    </>
  );
}

function SingleTokenTab({
  tokens,
}: {
  tokens: BigNumberish[]
  switchOnMint?: boolean
}) {
  const { token_id, hash_token_id } = useTokenId()

  const tokenCount = useMemo(() => tokens.length, [tokens])
  const pageIndex = useMemo(() => tokens.findIndex(token => token_id == Number(token)), [tokens, token_id])

  const _changePage = (newPageIndex: number) => {
    let tokenId = tokens[newPageIndex] ?? 1
    goToTokenPage(Number(tokenId));
  }

  return (
    <>
      <Token />
      <Navigation
        pageCount={tokenCount}
        pageIndex={pageIndex}
        onPageChange={_changePage}
      />
    </>
  );
}


function OwnedTokensTab() {


  // // reload page if when minted
  // useEffect(() => {
  //   if (!hash_token_id) {
  //     _changePage(total_supply)
  //   }
  // }, [total_supply])


  return (
    <>
      <Token />
      {/* <Navigation /> */}
    </>
  );
}



