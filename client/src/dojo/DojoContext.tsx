import { ReactNode, createContext, useContext } from "react";
import { Account, AccountInterface } from "starknet";
import { SetupResult } from "./generated/setup";
import { useAccount } from "@starknet-react/core";

interface DojoContextType extends SetupResult {
  masterAccount: AccountInterface | undefined;
  // account: BurnerAccount;
}

export const DojoContext = createContext<DojoContextType | null>(null);

export const DojoProvider = ({
  children,
  value,
}: {
  children: ReactNode;
  value: SetupResult;
}) => {
  const currentValue = useContext(DojoContext);
  if (currentValue) throw new Error("DojoProvider can only be used once");

  let masterAccount: AccountInterface | undefined = undefined;

  const { account: walletAccount } = useAccount();

  const {
    config: { masterAddress, masterPrivateKey },
    dojoProvider,
  } = value;

  if (walletAccount) {
    masterAccount = walletAccount;
  } else {
    masterAccount = new Account(
      dojoProvider.provider,
      masterAddress,
      masterPrivateKey,
      "1"
    );
  }

  return (
    <DojoContext.Provider
      value={{
        ...value,
        masterAccount,
      }}
    >
      {children}
    </DojoContext.Provider>
  );
};
