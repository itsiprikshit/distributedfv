test tcSingleClientNoFailure [main = SingleClient]:
  union TwoPhaseCommit, TwoPCClient, { SingleClient };

test tcMultipleClientsNoFailure [main = MultipleClients]:
  assert AtomicityInvariant, Progress in
    (union TwoPhaseCommit, TwoPCClient, { MultipleClients });