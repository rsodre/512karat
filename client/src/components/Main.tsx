import { useMemo } from "react";
import { Grid, Button } from "semantic-ui-react";
import { MetadataProvider } from "../hooks/MetadataContext";
import { useAccount } from "@starknet-react/core";
import { useTokenIdFromUrl } from "../hooks/useTokenIdFromUrl";
import { TokenSet, useStateContext } from "../hooks/StateContext";
import { goToTokenPage } from "../utils/karat";
import Token from "./Token";
import Navigation from "./Navigation";
import TokenGrid from "./TokenGrid";
import InfoPanel from "./InfoPanel";

const Row = Grid.Row
const Col = Grid.Column

export default function Main() {
  // this hook will keep StateContext in sync with the URL
  useTokenIdFromUrl()

  const { isConnected, address } = useAccount();
  const { gridMode, tokenSet, allTokenIds, tokenIdsOfOwner, dispatchSetTokenSet } = useStateContext();

  const _changedTab = (tokenSet: TokenSet) => {
    dispatchSetTokenSet(tokenSet)
    goToTokenPage(0);
  }

  return (
    <MetadataProvider>
      <Grid>
        <Row columns={'equal'}>
          <Col>
            <Button fluid secondary toggle active={tokenSet == TokenSet.All} onClick={() => _changedTab(TokenSet.All)}>
              {`Collection (${allTokenIds.length})`}
            </Button>
          </Col>
          <Col>
            <Button fluid secondary toggle active={tokenSet == TokenSet.Collected} disabled={!isConnected} onClick={() => _changedTab(TokenSet.Collected)}>
              {`Collected (${tokenIdsOfOwner.length})`}
            </Button>
          </Col>
          <Col>
            <Button fluid secondary toggle active={tokenSet == TokenSet.Info} disabled={!isConnected} onClick={() => _changedTab(TokenSet.Info)}>
              {`Info`}
            </Button>
          </Col>
        </Row>
        <Row columns={'equal'}>
          <Col>
            {tokenSet == TokenSet.Info ?
              <InfoPanel />
              : <>
                {gridMode && <MultiTokenTab />}
                {!gridMode && <SingleTokenTab />}
              </>
            }
          </Col>
        </Row>
      </Grid>
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

