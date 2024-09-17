
export const goToTokenPage = (token_id: number) => {
  const url = token_id ? `#${token_id}` : '';
  window.location.hash = url
}
