import { Pagination } from "semantic-ui-react";
import { useTokenId } from "../hooks/useTokenId";
import { useEffect } from "react";

export const goToTokenPage = (token_id: number, total_supply?: number) => (
  (!token_id || token_id == total_supply)
    ? window.location.hash = ''
    : window.location.hash = `#${token_id}`
)

export default function Navigation() {
  const { token_id, total_supply, hash_token_id } = useTokenId()

  const _changePage = (activePage: number) => {
    goToTokenPage(activePage, total_supply);
  }

  useEffect(() => {
    if (!hash_token_id) {
      _changePage(total_supply)
    }
  }, [total_supply])

  return (
    <Pagination
      defaultActivePage={token_id}
      activePage={token_id}
      firstItem={null}
      lastItem={null}
      pointing
      secondary
      totalPages={total_supply}
      onPageChange={(e, { activePage }) => _changePage(Number(activePage ?? total_supply))}
      className='Navigation'
    />
  );
}
