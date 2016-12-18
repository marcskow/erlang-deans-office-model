-module(dziekanat).

-import(dataGenerator, [generateFieldOfStudy/0,toString/1]).
-import(obsluga,[getTicket/5,student/1,secretary/2,screen/5]).
-import(,[new/0]).

-compile([export_all]).
%% API
%-export([]).
%secretary(FoS, Num) ->
%secretary(FoS, Scr, Num) ->
main(NW) ->
  random:seed(erlang:now()),
  TicketMachinePid = spawn(obsluga, getTicket, [1,1,1,1]),
  ScreenPid = spawn(obsluga,screen,[1,1,1,1]),
  SecretaryPidList = [spawn(obsluga, secretary, [elektrotechnika, ScreenPid,1]),
    spawn(obsluga,secretary,[automatyka, ScreenPid,1]),
    spawn(obsluga,secretary,[informatyka, ScreenPid,1]),
    spawn(obsluga,secretary,[biomedyczna, ScreenPid,1])],
  start(TicketMachinePid, SecretaryPidList, ScreenPid,NW)
.

start(_,_,_,0) -> io:fwrite("koniec");

start(TicketMachinePid, SLPids, ScreenPid,NW) ->
 % student(FoS,Scr,Sec,T) ->
  FoS = generateFieldOfStudy(),
  SecretaryPid = getSecretaryPid(FoS, SLPids),

  io:fwrite("Wszedl student kierunku: "),
  io:fwrite(toString(FoS)),
  io:fwrite("~n"),


  StudentPid = spawn(obsluga, student, [FoS, ScreenPid, SecretaryPid, -1]),
  timer:sleep(3000),
  TicketMachinePid ! {StudentPid, FoS},
  timer:sleep(2000),
  start(TicketMachinePid, SLPids, ScreenPid,NW-1)
.
addToList(L,S,informatyka) ->
  [E,A,I,IB] = L,
  [E,A,lists:append(I,[S]),IB];
addToList(L,S,elektrotechnika) ->
  [E,A,I,IB] = L,
  [lists:append(E,[S]),A,I,IB];
addToList(L,S,automatyka) ->
  [E,A,I,IB] = L,
  [E,lists:append(A,[S]),I,IB];
addToList(L,S,biomedyczna) ->
  [E,A,I,IB] = L,
  [E,A,I,lists:append(IB,[S])].

getSecretaryPid(informatyka,[_,_,I,_]) -> I;
getSecretaryPid(elektrotechnika,[E,_,_,_]) -> E;
getSecretaryPid(biomedyczna,[_,_,_,IB]) -> IB;
getSecretaryPid(automatyka,[_,A,_,_]) -> A.


cudo()->
  a = io:read("a"),
  io:fwrite("dostalem ~p",[a]).