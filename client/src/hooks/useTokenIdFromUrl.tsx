import { useEffect, useMemo } from "react";
import { useLocation } from "react-router-dom";
import { useStateContext } from "./StateContext";

export const useTokenIdFromUrl = () => {
  const { hash } = useLocation();
  const hash_token_id = useMemo(() => Number(hash.split('#')[1] ?? 0), [hash]);

  const { dispatchSetTokenId } = useStateContext()
  useEffect(() => {
    console.log('>>> #ID:', hash_token_id)
    if (hash_token_id) {
      dispatchSetTokenId(hash_token_id)
    }
  }, [hash_token_id])

  return {
    hash_token_id,
  }
}

