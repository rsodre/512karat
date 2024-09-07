
import { useMemo } from 'react'
import { Connector } from '@starknet-react/core'
import CartridgeConnector from '@cartridge/connector'
import { Policy, ControllerOptions, PaymasterOptions } from "@cartridge/controller";
import { Manifest } from '@dojoengine/core'
import { bigintToHex } from '../utils/types';
import { stringToFelt } from '../utils/starknet';


export interface ContractInterfaces {
  [contractName: string]: string[]
}

const exclusions = [
  'dojo_init',
]

export const makeController = (manifest: Manifest, rpcUrl: string, nameSpace: string, contractInterfaces: ContractInterfaces) => {
  const paymaster: PaymasterOptions = {
    caller: bigintToHex(stringToFelt("ANY_CALLER")),
  }
  const policies: Policy[] = []
  // contracts
  manifest?.contracts.forEach((contract) => {
    // Manifest is outdated
    //@ts-ignore
    const tag = contract.tag
    const contractName = tag.split(`${nameSpace}-`).at(-1)
    const interfaces = contractInterfaces[contractName]
    if (interfaces) {
      // abis
      contract.abi.forEach((abi) => {
        // interfaces
        const interfaceName = abi.name.split('::').slice(-1)[0]
        // console.log(`CI:`, contractName, interfaceName)
        if (abi.type == 'interface' && interfaces.includes(interfaceName)) {
          abi.items.forEach((item) => {
            // functions
            const method = item.name
            if (item.type == 'function' && item.state_mutability == 'external' && !exclusions.includes(method)) {
              // console.log(`CI:`, item.name, item)
              //@ts-ignore
              policies.push({
                target: contract.address,
                method,
                description: `${tag}::${item.name}()`,
              })
            }
          })
        }
      })
    }
  })
  const options: ControllerOptions = {
    paymaster,
    rpc: rpcUrl,
    // theme: "pistols",
    colorMode: "dark",
    policies,
  }
  // console.log(`CONTROLLER:`, options)
  return new CartridgeConnector(options) as never as Connector
}

export const useController = (manifest: Manifest, rpcUrl: string, nameSpace: string, contractInterfaces: ContractInterfaces) => {
  const controller = useMemo(() => makeController(manifest, rpcUrl, nameSpace, contractInterfaces), [manifest])
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

