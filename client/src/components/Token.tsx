import { useMemo } from "react";
import { Divider, Grid, Icon, Image } from "semantic-ui-react";
import { useTokenId } from "../hooks/useTokenId";
import { useTokenUri } from "../hooks/useTokenUri";
import { useTokenOwner, useTotalSupply } from "../hooks/useToken";
import { AddressShort } from "./ui/AddressShort";

const Row = Grid.Row
const Col = Grid.Column

export default function Token() {
  const { token_id } = useTokenId()
  const { tokenExists, name, image, attributes, isLoading } = useTokenUri(token_id);
  const { ownerAddress } = useTokenOwner(token_id);
  const { total_supply } = useTotalSupply()

  const fakeAttributes = useMemo(() => ({
    'Class': '...',
    'Realm': '...',
  }), [])

  let attributesRows = useMemo(() => Object.keys(attributes ?? fakeAttributes).map(key => (
    <Row key={key} columns={'equal'} className="AttributeRow">
      <Col textAlign="left">
        {key}
      </Col>
      <Col textAlign="right">
        {(attributes ?? fakeAttributes)[key]}
      </Col>
    </Row>
  )), [attributes, isLoading])

  return (
    <Grid>
      <Row columns={'equal'}>
        <Col>
          <Image src={image ?? '/images/placeholder.svg'} size='big' centered spaced />
          {!image &&
            <div className="PlaceholderOverlay">
              <Icon name='spinner' loading size='big' />
            </div>
          }
        </Col>
      </Row>

      {/* <Row columns={'equal'} className="AttributeRow">
        <Col textAlign="left">
          <h5>{name}</h5>
        </Col>
        <Col textAlign="right">
          {token_id.toString()} of {total_supply}
        </Col>
      </Row> */}

      <Row columns={'equal'} className="AttributeRow">
        <Col textAlign="center">
          <h4>{name}</h4>
        </Col>
      </Row>

      {attributesRows}

      <Row columns={'equal'} className="AttributeRow">
        <Col textAlign="left">
          Owner
        </Col>
        <Col textAlign="right">
          {isLoading ? '...' : <AddressShort address={ownerAddress ?? 0} />}
        </Col>
      </Row>

    </Grid>
  );
}
