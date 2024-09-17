import { useMemo } from "react";
import { Grid, Icon, Image } from "semantic-ui-react";
import { useTokenOwner } from "../hooks/useToken";
import { useTokenUri } from "../hooks/useTokenUri";
import { AddressShort } from "./ui/AddressShort";
import { useStateContext } from "../hooks/StateContext";

const Row = Grid.Row
const Col = Grid.Column

export default function Token() {
  const { tokenId } = useStateContext()
  const { name, image, attributes, isLoading } = useTokenUri(tokenId);
  const { ownerAddress } = useTokenOwner(tokenId);

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
