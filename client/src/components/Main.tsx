import { useEffect, useMemo, useState } from "react";
import { Grid, TabPane, Tab, TabProps } from "semantic-ui-react";
import { useAccount } from "@starknet-react/core";
import { useTokenId } from "../hooks/useTokenId";
import { goToTokenPage } from "../utils/karat";
import Token from "./Token";
import Navigation from "./Navigation";
import { useAllTokensOfOwner, useTotalSupply } from "../hooks/useToken";
import { BigNumberish } from "starknet";
import TokenGrid from "./TokenGrid";

const Row = Grid.Row
const Col = Grid.Column

export default function Main() {
  const { isConnected, address } = useAccount();
  const { token_id, hash_token_id } = useTokenId()
  let gridMode = !Boolean(hash_token_id);

  // All tokens
  const { total_supply } = useTotalSupply();
  const allTokens = useMemo(() => {
    return Array.from({ length: total_supply }, (_, i) => i + 1)
  }, [total_supply])

  // tokens of owner
  const { tokenIds: tokensOfOwner } = useAllTokensOfOwner(address ?? 0n)
  // useEffect(() => {
  //   if (token_id && hash_token_id && tokensOfOwner.length > 0) {
  //     goToTokenPage(token_id);
  //   }
  // }, [token_id, hash_token_id, tokensOfOwner.length])

  const _changedTab = (data: TabProps) => {
    goToTokenPage(0);
  }

  const panes = useMemo(() => {
    let result = [
      {
        menuItem: `Collection (${allTokens.length})`,
        render: () => (
          <TabPane attached={false}>
            {gridMode && <MultiTokenTab tokens={allTokens} />}
            {!gridMode && <SingleTokenTab tokens={allTokens} />}
          </TabPane>
        )
      },
    ]
    if (isConnected) {
      result.push({
        menuItem: `Collected (${tokensOfOwner.length})`,
        render: () => (
          <TabPane attached={false}>
            {gridMode && <MultiTokenTab tokens={tokensOfOwner} />}
            {!gridMode && <SingleTokenTab tokens={tokensOfOwner} />}
          </TabPane>
        )
      })
    }
    return result
  }, [isConnected, gridMode, allTokens, tokensOfOwner])

  return (
    <>
      <Tab menu={{ secondary: true, pointing: true, attached: true }} panes={panes} onTabChange={(e, data) => _changedTab(data)} />
    </>
  );
}

function SingleTokenTab({
  tokens,
  switchOnMint = false,
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


function MultiTokenTab({
  tokens,
}: {
  tokens: BigNumberish[]
}) {
  const gridSize = 9;
  const pageCount = useMemo(() => Math.ceil(tokens.length / gridSize), [tokens, gridSize])
  const [pageIndex, setPageIndex] = useState(0)
  const firstTokenIndex = useMemo(() => (pageIndex * gridSize), [pageIndex, gridSize])

  const _changePage = (newPageIndex: number) => {
    setPageIndex(newPageIndex);
  }

  return (
    <>
      <TokenGrid
        tokens={tokens}
        gridSize={gridSize}
        firstTokenIndex={firstTokenIndex}
      />
      <Navigation
        pageCount={pageCount}
        pageIndex={pageIndex}
        onPageChange={_changePage}
        prefix='Page'
      />
    </>
  );
}


