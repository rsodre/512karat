import { useEffect, useMemo, useState } from "react";
import { Grid, TabPane, Tab, TabProps } from "semantic-ui-react";
import { BigNumberish } from "starknet";
import { MetadataProvider } from "../hooks/MetadataContext";
import { useStateContext } from "../hooks/StateContext";
import { useAccount } from "@starknet-react/core";
import { useTokenIdFromUrl } from "../hooks/useTokenIdFromUrl";
import { useAllTokensOfOwner, useTotalSupply } from "../hooks/useToken";
import { goToTokenPage } from "../utils/karat";
import Token from "./Token";
import Navigation from "./Navigation";
import TokenGrid from "./TokenGrid";

const Row = Grid.Row
const Col = Grid.Column

export default function Main() {
  // this hook will keep StateContext in sync with the URL
  useTokenIdFromUrl()

  const { isConnected, address } = useAccount();
  const { tokenId, gridMode, gridSize } = useStateContext();

  // All tokens
  const { total_supply } = useTotalSupply();
  const allTokens = useMemo(() => {
    return Array.from({ length: total_supply }, (_, i) => i + 1)
  }, [total_supply])

  // tokens of owner
  const { tokenIds: tokensOfOwner } = useAllTokensOfOwner(address ?? 0n)

  const _changedTab = (data: TabProps) => {
    // const pageIndex = tokenId ? Math.floor(tokenId / gridSize) : 0;
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
    <MetadataProvider>
      <Tab menu={{ secondary: true, pointing: true, attached: true }} panes={panes} onTabChange={(e, data) => _changedTab(data)} />
    </MetadataProvider>
  );
}

function SingleTokenTab({
  tokens,
  switchOnMint = false,
}: {
  tokens: BigNumberish[]
  switchOnMint?: boolean
}) {
  const { tokenId } = useStateContext();

  const tokenCount = useMemo(() => tokens.length, [tokens])
  const pageIndex = useMemo(() => tokens.findIndex(token => tokenId == Number(token)), [tokens, tokenId])

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
  const { gridSize } = useStateContext();

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


