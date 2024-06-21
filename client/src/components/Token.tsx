import { Grid, Image } from "semantic-ui-react";
import { BigNumberish } from "starknet";
import { useTokenUri } from "../hooks/useTokenUri";
import { useTokenOwner, useTotalSupply } from "../hooks/useToken";
import { AddressShort } from "./AddressShort";

const Row = Grid.Row
const Col = Grid.Column

export default function TokenRows({
  token_id,
}: {
  token_id: BigNumberish
}) {
  const { tokenExists, name, image, attributes } = useTokenUri(token_id);
  const { ownerAddress } = useTokenOwner(token_id);
  const { total_supply } = useTotalSupply()

  let attributesRows = Object.keys(attributes ?? {}).map(key => (
    <Row key={key} columns={'equal'} className="AttributeRow">
      <Col textAlign="left">
        {key}
      </Col>
      <Col textAlign="right">
        {attributes[key]}
      </Col>
    </Row>
  ))

  return (
    <>
      <Row columns={'equal'}>
        <Col>
          <Image src={image ?? '/images/placeholder.svg'} size='large' centered spaced/>
        </Col>
      </Row>
      {tokenExists && <>
        <Row columns={'equal'}>
          <Col textAlign="left">
            <h5>{name}</h5>
          </Col>
          <Col textAlign="right">
            {token_id.toString()} of {total_supply}
          </Col>
        </Row>
        {attributesRows}
        <Row columns={'equal'} className="AttributeRow">
          <Col textAlign="left">
            Owner
          </Col>
          <Col textAlign="right">
            <AddressShort address={ownerAddress ?? 0} />
          </Col>
        </Row>
      </>}
    </>
  );
}
