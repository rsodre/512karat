import { Button, Grid, Icon, Pagination } from "semantic-ui-react";
import { useTokenId } from "../hooks/useTokenId";
import { useEffect, useMemo } from "react";

const Row = Grid.Row
const Col = Grid.Column


export default function Navigation({
  pageCount,
  pageIndex,
  onPageChange,
  disabled = false,
  prefix = '',
}: {
  pageCount: number
  pageIndex: number
  onPageChange: (page: number) => void
  disabled?: boolean
  prefix?: string
}) {

  const canGoPrev = useMemo(() => (!disabled && pageIndex > 0), [disabled, pageIndex])
  const canGoNext = useMemo(() => (!disabled && pageIndex >= 0 && pageIndex < pageCount - 1), [disabled, pageIndex, pageCount])

  const _gotoFirstPage = () => {
    if (canGoPrev) onPageChange(0);
  }
  const _gotoPrevPage = () => {
    if (canGoPrev) onPageChange(pageIndex - 1);
  }
  const _gotoNextPage = () => {
    if (canGoNext) onPageChange(pageIndex + 1);
  }
  const _gotoLastPage = () => {
    if (canGoNext) onPageChange(pageCount - 1);
  }

  return (
    <Grid>
      <Row>
        <Col width={4} className={canGoPrev ? '' : 'NoMouse'}>
          <Button fluid disabled={!canGoPrev} onClick={() => _gotoPrevPage()}><Icon disabled={!canGoPrev} name='angle left' className='NoMargin' /></Button>
        </Col>
        <Col width={2} className={canGoPrev ? '' : 'NoMouse'}>
          <Button fluid disabled={!canGoPrev} onClick={() => _gotoFirstPage()}><Icon disabled={!canGoPrev} name='angle double left' className='NoMargin' /></Button>
        </Col>
        
        <Col width={4} verticalAlign="middle">
          {pageIndex < 0 ? '...' : `${prefix} ${pageIndex + 1} of ${pageCount}`}
        </Col>

        <Col width={2} className={canGoNext ? '' : 'NoMouse'}>
          <Button fluid disabled={!canGoNext} onClick={() => _gotoLastPage()}><Icon disabled={!canGoNext} name='angle double right' className='NoMargin' /></Button>
        </Col>
        <Col width={4} className={canGoNext ? '' : 'NoMouse'}>
          <Button fluid disabled={!canGoNext} onClick={() => _gotoNextPage()}><Icon disabled={!canGoNext} name='angle right' className='NoMargin' /></Button>
        </Col>
      </Row>
    </Grid>
  );
}








// export default function Navigation() {
//   const { token_id, total_supply, hash_token_id } = useTokenId()

//   const _changePage = (activePage: number) => {
//     goToTokenPage(activePage);
//   }

//   useEffect(() => {
//     if (!hash_token_id) {
//       _changePage(total_supply)
//     }
//   }, [total_supply])

//   return (
//     <Pagination
//       defaultActivePage={token_id}
//       activePage={token_id}
//       firstItem={null}
//       lastItem={null}
//       pointing
//       secondary
//       totalPages={total_supply}
//       onPageChange={(e, { activePage }) => _changePage(Number(activePage ?? total_supply))}
//       className='Navigation'
//     />
//   );
// }
