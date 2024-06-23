import React, { useState } from 'react'
import { Modal, Button, Image, Grid } from 'semantic-ui-react'
import { useConnect, useAccount } from '@starknet-react/core'
import { Opener } from '../hooks/useOpener'
import { useEffectOnce } from '../hooks/useEffectOnce'

const Row = Grid.Row
const Col = Grid.Column

export default function ConnectModal({
  opener,
  walletHelp = false,
}: {
  opener: Opener
  walletHelp?: boolean
}) {
  const { isConnected } = useAccount()

  // always closed on mount
  const [mounted, setMounted] = useState(false)
  useEffectOnce(() => {
    setMounted(true)
    opener.close()
  }, [])

  return (
    <Modal
      size='mini'
      onClose={() => opener.close()}
      open={mounted && opener.isOpen}
    >
      <Modal.Content>
        {!isConnected ? <ConnectButtons walletHelp={walletHelp} />
          : <></>
        }
      </Modal.Content>
    </Modal>
  )
}

function ConnectButtons({
  walletHelp,
}: {
  walletHelp: boolean
}) {
  const { isConnecting } = useAccount()
  const { connect, connectors } = useConnect()
  // console.log(`connectors:`, connectors)
  return (
    <Grid>
        {connectors.map((connector) => {
          const logo = connector.icon.dark?.startsWith('<svg') ? `data:image/svg+xml;base64,${btoa(connector.icon.dark)}` : connector.icon.dark;
          const disabled = !connector.available() || isConnecting;
          return (
          <Row columns={1} key={connector.id}>
            <Col>
              <Button fluid disabled={disabled} onClick={() => connect({ connector })} className='Flex'>
                {connector.name}
                  <Image spaced src={logo} style={{ maxHeight: '1.25em' }} className={disabled ? 'IconInactive' : ''}/>
              </Button>
            </Col>
          </Row>
          )
        })}
    </Grid>
  )
}
