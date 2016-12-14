-module(dziekanat).

-import(dataGenerator, [generateStudent/0,toString/1]).
-import(obsluga,[getTicket/5,student/1,secretary/2,screen/5]).

-compile([export_all]).
%% API
%-export([]).
%secretary(FoS, Num) ->
main() ->
  random:seed(erlang:now()),
  TicketAutomat = spawn(obsluga, getTicket, [1,1,1,1,1]),
  SecretaryList = [spawn(obsluga, secretary, [elektrotechnika,1]),
    spawn(obsluga,secretary,[automatyka,1]),
    spawn(obsluga,secretary,[informatyka,1]),
    spawn(obsluga,secretary,[biomedyczna,1]),
    spawn(obsluga,secretary,[mikroelektronika,1])],
  Screen = spawn(obsluga,screen,[1,1,1,1,1]),

  start(TicketAutomat, SecretaryList, Screen)
.

start(A,SL,S) ->
  {Pid,FoS} = generateStudent(),

  io:fwrite("Wszedl student kierunku: "),
  io:fwrite(toString(FoS)),
  io:fwrite("~n"),

  A ! {Pid, FoS},
  timer:sleep(2000),
  start(A,SL,S).

addToList(L,S,informatyka) ->
  [E,A,I,IB,M] = L,
  [E,A,lists:append(I,[S]),IB,M];
addToList(L,S,elektrotechnika) ->
  [E,A,I,IB,M] = L,
  [lists:append(E,[S]),A,I,IB,M];
addToList(L,S,automatyka) ->
  [E,A,I,IB,M] = L,
  [E,lists:append(A,[S]),I,IB,M];
addToList(L,S,biomedyczna) ->
  [E,A,I,IB,M] = L,
  [E,A,I,lists:append(IB,[S]),M];
addToList(L,S,mikroelektronika) ->
  [E,A,I,IB,M] = L,
  [E,A,I,IB,lists:append(M,[S])].
