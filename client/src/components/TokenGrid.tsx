import { useMemo } from "react";
import { Grid, Icon, Image, SemanticWIDTHS } from "semantic-ui-react";
import { BigNumberish } from "starknet";
import { useTotalSupply } from "../hooks/useToken";
import { useTokenUri } from "../hooks/useTokenUri";
import { goToTokenPage } from "../utils/karat";

const Row = Grid.Row
const Col = Grid.Column

export default function TokenGrid({
  tokens,
  gridSize,
  firstTokenIndex,
}: {
  tokens: BigNumberish[]
  gridSize: number
  firstTokenIndex: number
}) {
  const columnsCount = useMemo(() => Math.floor(Math.sqrt(gridSize)) as SemanticWIDTHS, [gridSize])
  const gridCount = useMemo(() => Math.min(gridSize, tokens.length - firstTokenIndex), [gridSize, tokens.length, firstTokenIndex])

  let columns = useMemo(() => {
    let result = []
    for (let i = 0; i < gridCount; i++) {
      const tokenId = tokens[firstTokenIndex + i]
      result.push(
        <Col key={`${tokenId}`}>
          <TokenImage tokenId={tokenId} />
        </Col>
      )
    }
    return result
  }, [tokens, firstTokenIndex, gridSize])

  return (
    <Grid>
      <Row columns={columnsCount}>
        {columns}
      </Row>
    </Grid>
  );
}

function TokenImage({
  tokenId,
}: {
  tokenId: BigNumberish
}) {
  const { image, isLoading } = useTokenUri(tokenId);
  const classNames = useMemo(() => {
    const classes = ['Padded']
    if (!isLoading) classes.push('Anchor')
    return classes.join(' ')
  }, [isLoading])

  const _click = () => {
    if (!isLoading && image) {
      goToTokenPage(Number(tokenId));
    }
  }
  return (
    <div>
      <Image src={image ?? '/images/placeholder.svg'} fluid centered spaced className={classNames} onClick={_click} />
      {isLoading &&
        <div className="PlaceholderOverlay">
          <Icon name='spinner' loading size='large' />
        </div>
      }
      <div className="PlaceholderOverlayId">
        {`#${tokenId}`}
      </div>
    </div>
  );
}
