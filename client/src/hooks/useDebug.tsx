import { useMemo } from 'react'

export function useDebug() {
  const isDebug = useMemo(() => (import.meta.env.VITE_DEBUG == '1'), [])
  return {
    isDebug,
  }
}
