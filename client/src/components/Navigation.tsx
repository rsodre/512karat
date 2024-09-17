import { Button, Grid, Icon } from "semantic-ui-react";
import { useMemo } from "react";

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
      <Row columns={'equal'}>
        <Col width={5} className={canGoPrev ? '' : 'NoMouse'}>
          <Button fluid disabled={!canGoPrev} onClick={() => _gotoPrevPage()}><Icon disabled={!canGoPrev} name='angle left' className='NoMargin' /></Button>
        </Col>
        <Col width={2} className={canGoPrev ? '' : 'NoMouse'}>
          <Button fluid disabled={!canGoPrev} onClick={() => _gotoFirstPage()}><Icon disabled={!canGoPrev} name='angle double left' className='NoMargin' /></Button>
        </Col>
        
        <Col width={2} verticalAlign="middle">
          {pageIndex < 0 ? '...' : `${pageIndex + 1} / ${pageCount}`}
        </Col>

        <Col width={2} className={canGoNext ? '' : 'NoMouse'}>
          <Button fluid disabled={!canGoNext} onClick={() => _gotoLastPage()}><Icon disabled={!canGoNext} name='angle double right' className='NoMargin' /></Button>
        </Col>
        <Col width={5} className={canGoNext ? '' : 'NoMouse'}>
          <Button fluid disabled={!canGoNext} onClick={() => _gotoNextPage()}><Icon disabled={!canGoNext} name='angle right' className='NoMargin' /></Button>
        </Col>
      </Row>
    </Grid>
  );
}

