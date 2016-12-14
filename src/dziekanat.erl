-module(dziekanat).

-import(dataGenerator, [generateFieldOfStudy/0,toString/1]).
-import(obsluga,[getTicket/5,student/1,secretary/2,screen/5]).

-compile([export_all]).
%% API
%-export([]).
%secretary(FoS, Num) ->
%secretary(FoS, Scr, Num) ->
main(NW) ->
  random:seed(erlang:now()),
  TicketMachine = spawn(obsluga, getTicket, [1,1,1,1]),
  Screen = spawn(obsluga,screen,[1,1,1,1]),
  SecretaryList = [spawn(obsluga, secretary, [elektrotechnika,Screen,1]),
    spawn(obsluga,secretary,[automatyka,Screen,1]),
    spawn(obsluga,secretary,[informatyka,Screen,1]),
    spawn(obsluga,secretary,[biomedyczna,Screen,1])],
  start(TicketMachine, SecretaryList, Screen,NW)
.

start(_,_,_,0) -> io:fwrite("");

start(A,SL,Scr,NW) ->
 % student(FoS,Scr,Sec,T) ->
  FoS = generateFieldOfStudy(),
  Sec = getSecretary(FoS,SL),

  io:fwrite("Wszedl student kierunku: "),
  io:fwrite(toString(FoS)),
  io:fwrite("~n"),


  Student = spawn(obsluga, student, [FoS, Scr, Sec, -1]),
  timer:sleep(3000),
  A ! {Student, FoS},
  timer:sleep(2000),
  start(A,SL,Scr,NW-1)
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

getSecretary(informatyka,[_,_,I,_]) -> I;
getSecretary(elektrotechnika,[E,_,_,_]) -> E;
getSecretary(biomedyczna,[_,_,_,IB]) -> IB;
getSecretary(automatyka,[_,A,_,_]) -> A.