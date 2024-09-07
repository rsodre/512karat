import React, { useState } from 'react'
import { Modal, Grid, Icon, Segment, Container } from 'semantic-ui-react'
import { Opener } from '../hooks/useOpener'
import { useEffectOnce } from '../hooks/useEffectOnce'

const Row = Grid.Row
const Col = Grid.Column

export default function MintModal({
  opener,
  isMinting,
}: {
  opener: Opener
    isMinting: boolean
}) {
  // always closed on mount
  const [mounted, setMounted] = useState(false)
  useEffectOnce(() => {
    setMounted(true)
    opener.close()
  }, [])

  return (
    <Modal
      basic
      onClose={() => opener.close()}
      open={mounted && opener.isOpen && isMinting}
      size='tiny'
    >
      <Modal.Content className='NoBorder'>
        <Container textAlign='center'>
          <h3>Minting...</h3>
        </Container>
      </Modal.Content>
    </Modal>
  )
}

