event eSpec_BankBalanceIsAlwaysCorrect_Init: map[int, int];

spec BankBalanceIsAlwaysCorrect observes eWithDrawReq,  eWithDrawResp, eSpec_BankBalanceIsAlwaysCorrect_Init {
  var bankBalance: map[int, int];
  var pendingWithDraws: map[int, tWithDrawReq];

  start state Init {
    on eSpec_BankBalanceIsAlwaysCorrect_Init goto WaitForWithDrawReqAndResp with (balance: map[int, int]){
      bankBalance = balance;
    }
  }

  state WaitForWithDrawReqAndResp {
    on eWithDrawReq do (req: tWithDrawReq) {
      assert req.accountId in bankBalance,
        format ("Unknown accountId {0} in the withdraw request. Valid accountIds = {1}",
          req.accountId, keys(bankBalance));
      pendingWithDraws[req.rId] = req;
    }

    on eWithDrawResp do (resp: tWithDrawResp) {
      assert resp.accountId in bankBalance,
        format ("Unknown accountId {0} in the withdraw response!", resp.accountId);
      assert resp.rId in pendingWithDraws,
        format ("Unknown rId {0} in the withdraw response!", resp.rId);
      assert resp.balance >= 20,
        "Bank balance in all accounts must always be greater than or equal to 20!!";

      if(resp.status == WITHDRAW_SUCCESS)
      {
        assert resp.balance == bankBalance[resp.accountId] - pendingWithDraws[resp.rId].amount,
          format ("Bank balance for the account {0} is {1} and not the expected value {2}, Bank is lying!",
            resp.accountId, resp.balance, bankBalance[resp.accountId] - pendingWithDraws[resp.rId].amount);
        bankBalance[resp.accountId] = resp.balance;
      }
      else
      {
        assert bankBalance[resp.accountId] - pendingWithDraws[resp.rId].amount < 20,
          format ("Bank must accept the withdraw request for {0}, bank balance is {1}!",
            pendingWithDraws[resp.rId].amount, bankBalance[resp.accountId]);
        assert bankBalance[resp.accountId] == resp.balance,
          format ("Withdraw failed BUT the account balance changed! actual: {0}, bank said: {1}",
            bankBalance[resp.accountId], resp.balance);
      }
    }
  }
}

spec GuaranteedWithDrawProgress observes eWithDrawReq, eWithDrawResp {
  var pendingWDReqs: set[int];

  start state NopendingRequests {
    on eWithDrawReq goto PendingReqs with (req: tWithDrawReq) {
      pendingWDReqs += (req.rId);
    }
  }

  hot state PendingReqs {
    on eWithDrawResp do (resp: tWithDrawResp) {
      assert resp.rId in pendingWDReqs,
        format ("unexpected rId: {0} received, expected one of {1}", resp.rId, pendingWDReqs);
      pendingWDReqs -= (resp.rId);
      if(sizeof(pendingWDReqs) == 0)
        goto NopendingRequests;
    }

    on eWithDrawReq goto PendingReqs with (req: tWithDrawReq){
      pendingWDReqs += (req.rId);
    }
  }
}
