import { useMemo } from "react";
import { useLocation } from "react-router-dom";
import { useTotalSupply } from "../hooks/useToken";

export const useTokenId = () => {
  const { total_supply } = useTotalSupply()
  const { hash } = useLocation();
  const hash_token_id = useMemo(() => (hash.split('#')[1] ?? null), [hash]);

  return {
    total_supply,
    hash_token_id: hash_token_id ? Number(hash_token_id) : null,
    token_id: hash_token_id ? Number(hash_token_id) : total_supply,
  }
}

