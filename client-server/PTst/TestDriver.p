machine TestManyClients
{
  start state Init {
    entry {
      SetupClientServerSystem(10);
    }
  }
}

fun CreateRandomInitialAccounts(numAccounts: int) : map[int, int]
{
  var i: int;
  var bankBalance: map[int, int];
  while(i < numAccounts) {
    bankBalance[i] = choose(100) + 20;
    i = i + 1;
  }
  return bankBalance;
}

fun SetupClientServerSystem(numClients: int)
{
  var i: int;
  var server: BankServer;
  var accountIds: seq[int];
  var initAccBalance: map[int, int];

  initAccBalance = CreateRandomInitialAccounts(numClients);
  server = new BankServer(initAccBalance);

  announce eSpec_BankBalanceIsAlwaysCorrect_Init, initAccBalance;

  accountIds = keys(initAccBalance);

  while(i < sizeof(accountIds)) {
    new Client((serv = server, accountId = accountIds[i], balance = initAccBalance[accountIds[i]]));
    i = i + 1;
  }
}