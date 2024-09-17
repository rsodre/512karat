import { useEffect, useMemo, useState } from "react";
import { Grid, TabPane, Tab, TabProps } from "semantic-ui-react";
import { BigNumberish } from "starknet";
import { MetadataProvider } from "../hooks/MetadataContext";
import { TokenSet, useStateContext } from "../hooks/StateContext";
import { useAccount } from "@starknet-react/core";
import { useTokenIdFromUrl } from "../hooks/useTokenIdFromUrl";
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
  const { gridMode, allTokenIds, tokenIdsOfOwner, dispatchSetTokenSet } = useStateContext();

  const _changedTab = (data: TabProps) => {
    dispatchSetTokenSet(data.activeIndex == 0 ? TokenSet.All : TokenSet.Collected)
    goToTokenPage(0);
  }

  const panes = useMemo(() => {
    let result = [
      {
        menuItem: `Collection (${allTokenIds.length})`,
        render: () => (
          <TabPane attached={false}>
            {gridMode && <MultiTokenTab />}
            {!gridMode && <SingleTokenTab />}
          </TabPane>
        )
      },
    ]
    if (isConnected) {
      result.push({
        menuItem: `Collected (${tokenIdsOfOwner.length})`,
        render: () => (
          <TabPane attached={false}>
            {gridMode && <MultiTokenTab />}
            {!gridMode && <SingleTokenTab />}
          </TabPane>
        )
      })
    }
    return result
  }, [isConnected, gridMode, allTokenIds, tokenIdsOfOwner])

  return (
    <MetadataProvider>
      <Tab menu={{ secondary: true, pointing: true, attached: true }} panes={panes} onTabChange={(e, data) => _changedTab(data)} />
    </MetadataProvider>
  );
}

function SingleTokenTab({
}: {
}) {
  const { tokenId } = useStateContext();
  const { tokenSetIds } = useStateContext();

  const tokenCount = useMemo(() => tokenSetIds.length, [tokenSetIds])
  const pageIndex = useMemo(() => tokenSetIds.findIndex(token => tokenId == Number(token)), [tokenSetIds, tokenId])

  const _changePage = (newPageIndex: number) => {
    let tokenId = tokenSetIds[newPageIndex] ?? 1
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
}: {
}) {
  const { gridSize } = useStateContext();
  const { tokenSetIds, pageIndex, dispatchSetPageIndex } = useStateContext();

  const pageCount = useMemo(() => Math.ceil(tokenSetIds.length / gridSize), [tokenSetIds, gridSize])
  const firstTokenIndex = useMemo(() => (pageIndex * gridSize), [pageIndex, gridSize])

  const _changePage = (newPageIndex: number) => {
    dispatchSetPageIndex(newPageIndex);
  }

  return (
    <>
      <TokenGrid
        tokens={tokenSetIds}
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


