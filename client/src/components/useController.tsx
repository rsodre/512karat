
import { useEffect, useMemo, useState } from 'react'
import { Connector, useAccount, useConnect } from '@starknet-react/core'
import CartridgeConnector from '@cartridge/connector'
import { Policy, ControllerOptions } from "@cartridge/controller";
import { Manifest } from '@dojoengine/core'

export const makeController = (manifest: Manifest, contractNames?: string[]) => {
  const options: ControllerOptions = {}
  const policies: Policy[] = []
  // contracts
  manifest?.contracts.forEach((contract) => {
    const contractName = contract.name.split('::').at(-1)
    if (!contractNames || contractNames.includes(contractName ?? '')) {
      // abis
      contract.abi.forEach((abi) => {
        // interfaces
        if (abi.type == 'interface') {
          abi.items.forEach((item) => {
            // functions
            if (item.type == 'function' && item.state_mutability == 'external') {
              policies.push({
                target: contract.address,
                method: item.name,
                description: `${contract.name}::${item.name}()`,
              })
            }
          })
        }
      })
    }
  })
  // console.log(`CONTROLLER:`, policies)
  return new CartridgeConnector(policies, options) as never as Connector
}

export const useController = (manifest: Manifest, contractNames?: string[]) => {
  const controller = useMemo(() => makeController(manifest, contractNames), [manifest])
  return {
    controller,
  }
}


// export const useControllerUsername = () => {
//   const { address, connector } = useAccount()
//   const [username, setUsername] = useState<string>(undefined)
//   const controllerConnector = useMemo(() => (connector as unknown as CartridgeConnector), [connector])
//   useEffect(() => {
//     setUsername(undefined)
//     if (address && controllerConnector?.username) {
//       controllerConnector.username().then((n) => setUsername(n))
//     }
//   }, [address, connector])
//   return {
//     username,
//   }
// }

