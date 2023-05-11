type tWithDrawReq = (source: Client, accountId: int, amount: int, rId:int);

type tWithDrawResp = (status: tWithDrawRespStatus, accountId: int, balance: int, rId: int);

enum tWithDrawRespStatus {
  WITHDRAW_SUCCESS,
  WITHDRAW_ERROR
}

event eWithDrawReq : tWithDrawReq;
event eWithDrawResp: tWithDrawResp;


machine Client
{
  var server : BankServer;
  var accountId: int;
  var nextReqId : int;
  var numOfWithdrawOps: int;
  var currentBalance: int;

  start state Init {

    entry (input : (serv : BankServer, accountId: int, balance : int))
    {
      server = input.serv;
      currentBalance =  input.balance;
      accountId = input.accountId;
      nextReqId = accountId*100 + 1;
      goto WithdrawMoney;
    }
  }

  state WithdrawMoney {
    entry {
      var index : int;

      if(currentBalance <= 20)
        goto NoMoneyToWithDraw;

      send server, eWithDrawReq, (source = this, accountId = accountId, amount = WithdrawAmount(), rId = nextReqId);
      nextReqId = nextReqId + 1;
    }

    on eWithDrawResp do (resp: tWithDrawResp) {
      assert resp.balance >= 20, "Bank balance must be greater than 20!!";

      if(resp.status == WITHDRAW_SUCCESS)
      {
        print format ("Withdrawal with rId = {0} succeeded, new account balance = {1}", resp.rId, resp.balance);
        currentBalance = resp.balance;
      }
      else
      {
        assert currentBalance == resp.balance,
          format ("Withdraw failed BUT the account balance changed! client thinks: {0}, bank balance: {1}", currentBalance, resp.balance);
        print format ("Withdrawal with rId = {0} failed, account balance = {1}", resp.rId, resp.balance);
      }

      if(currentBalance > 20)
      {
        print format ("Still have account balance = {0}, lets try and withdraw more", currentBalance);
        goto WithdrawMoney;
      }
    }
  }

  fun WithdrawAmount() : int {
    return choose(currentBalance) + 1;
  }

  state NoMoneyToWithDraw {
    entry {
      assert currentBalance == 20, "Hmm, I still have money that I can withdraw but I have reached NoMoneyToWithDraw state!";
      print format ("No Money to withdraw, waiting for more deposits!");
    }
  }
}