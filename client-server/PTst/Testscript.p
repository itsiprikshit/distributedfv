test tcSingleClientAbstractServer [main=TestManyClients]:
  assert BankBalanceIsAlwaysCorrect, GuaranteedWithDrawProgress in
  (union Client, Bank, { TestManyClients });