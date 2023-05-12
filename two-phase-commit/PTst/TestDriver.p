type t2PCConfig = (
  numClients: int,
  numParticipants: int,
  numTransPerClient: int
);

fun SetUpTwoPhaseCommitSystem(config: t2PCConfig)
{
  var coordinator : Coordinator;
  var participants: set[Participant];
  var i : int;

  while (i < config.numParticipants) {
    participants += (new Participant());
    i = i + 1;
  }

  InitializeTwoPhaseCommitSpecifications(config.numParticipants);

  coordinator = new Coordinator(participants);

  i = 0;
  while(i < config.numClients)
  {
    new Client((coordinator = coordinator, n = config.numTransPerClient, id = i + 1));
    i = i + 1;
  }
}

fun InitializeTwoPhaseCommitSpecifications(numParticipants: int) {
  announce eMonitor_AtomicityInitialize, numParticipants;
}

machine SingleClient {
  start state Init {
    entry {
      var config: t2PCConfig;

      config = (numClients = 1,
                      numParticipants = 3,
                      numTransPerClient = 2);

            SetUpTwoPhaseCommitSystem(config);
    }
  }
}

machine MultipleClients {
  start state Init {
    entry {
      var config: t2PCConfig;
      config = 
        (numClients = 2,
        numParticipants = 3,
        numTransPerClient = 2);

        SetUpTwoPhaseCommitSystem(config);
    }
  }
}
