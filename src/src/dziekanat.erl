-module(dziekanat).
-author('Marcin Skowron').
-author('Michal Kaldus').
-import(dataGenerator, [generateFieldOfStudy/0,toString/1,generateInteger/2]).
-import(obsluga,[getTicket/5,student/1,secretary/2,screen/5,dean/2]).
-import(constants,[timeUnit/0]).
-import(customTimer,[customTimer/1]).
-import(deansView,[initView/0,viewThread/0,studentMessageThread/0]).
-compile([export_all]).

studentPerTimeUnit() -> 4.

%% API
%-export([]).
%secretary(FoS, Num) ->
%secretary(FoS, Scr, Num) ->
main(NumberOfTimeUnits) ->
  random:seed(erlang:now()),
  deansView:initView(),
%%  timer:sleep(1000),
  View = spawn(deansView,viewThread,[]),
  spawn(deansView,input_reader,[]),
  Clock = spawn(customTimer, customTimerThread,[{poniedzialek,0,0,15,5,1,2016},View]),
  TicketMachine = spawn(obsluga, getTicket, [1,1,1,1,View]),
  Screen = spawn(obsluga,screen,[1,1,1,1]),
  Dean = spawn(obsluga,dean,[Screen,Clock,View]),
  SecretaryList = [spawn(obsluga, secretary, [elektrotechnika,Screen,Clock,1,View]),
    spawn(obsluga,secretary,[automatyka,Screen,Clock,1,View]),
    spawn(obsluga,secretary,[informatyka,Screen,Clock,1,View]),
    spawn(obsluga,secretary,[biomedyczna,Screen,Clock,1,View])],
  start(TicketMachine, SecretaryList, Dean, Screen, NumberOfTimeUnits, Clock,View),
  application:stop(cecho).



start(_,_,_,_,0,_,_) -> ok;

start(TicketMachine, SecretaryList, Dean, Screen, NumberOfTimeUnits, Clock,StudentMessage) ->
  Spawner = spawn(dziekanat,helperSpawner,[SecretaryList, Screen, Dean, TicketMachine, Clock,StudentMessage]),
  Spawner ! spawn,

  timer:sleep(constants:timeUnit()),
  Clock ! go,
  start(TicketMachine, SecretaryList, Dean, Screen, NumberOfTimeUnits-1, Clock,StudentMessage)
.

helperSpawner(SecretaryList, Screen, Dean, TicketMachine, Clock,StudentMessage) ->
  receive
    spawn ->
      Helper = spawn(dziekanat, multiStudentsSpawner, [SecretaryList, Screen, Dean, TicketMachine, Clock,StudentMessage]),
      Clock ! {Helper, get_time}
  end.

takie(DayInWeek,Day,Month,Hour,Month) -> studentPerTimeUnit() * week_day_factor(DayInWeek) * special_day_factor(Day,Month) * hour_factor(Hour) * month_factor(Month).

multiStudentsSpawner(SecretaryList, Screen, Dean, TicketMachine, Clock,StudentMessage) ->
  receive
    {DayInWeek,_,_,Hour,Day,Month,_} ->
      N = studentPerTimeUnit() * week_day_factor(DayInWeek) * special_day_factor(Day,Month) * hour_factor(Hour) * month_factor(Month),
      NN = getN(N),
     % io:fwrite("~B",[NN]),
      spawnSpawners(NN,SecretaryList, Screen, Dean, TicketMachine, Clock,StudentMessage)
  end.
% dziekanat:main(100000).
getN(0.0) -> 0;
getN(N) when N >= 1 -> round(N);
getN(N) when N < 1 ->
  X = generateInteger(0,round(1/N)),
 % io:fwrite("~B",[X]),
  if X =:= 1 -> 1;
     X =/= 1 -> 0
  end
.

spawnSpawner(SecretaryList, Screen, Dean, TicketMachine, Clock,StudentMessage) ->
  Spawner = spawn(dziekanat, singleStudentSpawner, [SecretaryList, Screen, Dean, TicketMachine, Clock,StudentMessage]),
  Spawner ! spawn.
spawnSpawners(0,_,_,_,_,_,_) -> void;
spawnSpawners(N, SecretaryList, Screen, Dean, TicketMachine, Clock,StudentMessage) ->
  spawnSpawner(SecretaryList, Screen, Dean, TicketMachine, Clock,StudentMessage),
  spawnSpawners(N-1, SecretaryList, Screen, Dean, TicketMachine, Clock,StudentMessage).

singleStudentSpawner(SecretaryList, Screen, Dean, TicketMachine, Clock,StudentMessage) ->
  receive
    spawn ->
      %timer:sleep(randomizeTimeout()),
      FieldOfStudy = generateFieldOfStudy(),
%%      io:format(lists:concat(["Wszedl student kierunku: ", toString(FieldOfStudy), ". ~n"])),
      Issue = generateIssue(),
      Student = spawn(obsluga, student, [FieldOfStudy, Issue, Screen, SecretaryList, Dean, TicketMachine, Clock, -1,StudentMessage]),
      Student ! go
  end.

generateIssue() -> randomizeIssue(generateInteger(0,8)).
randomizeIssue(X) when X >= 0, X < 4 -> general;
randomizeIssue(4) -> certificate;
randomizeIssue(5) -> certificate;
randomizeIssue(6) -> degree;
randomizeIssue(7) -> petition;
randomizeIssue(8) -> general.


randomizeTimeout() ->
  round(timeUnit() / generateInteger(1,10)).

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

% DIW H D Mo Y
week_day_factor(sobota) -> 0.0;
week_day_factor(niedziela) -> 0.0;
week_day_factor(czwartek) -> 0.1;
week_day_factor(_) -> 1.

special_day_factor(24,12) -> 0.0;
special_day_factor(25,12) -> 0.0;
special_day_factor(26,12) -> 0.0;
special_day_factor(27,12) -> 0.0;
special_day_factor(28,12) -> 0.0;
special_day_factor(29,12) -> 0.0;
special_day_factor(30,12) -> 0.0;
special_day_factor(1,1) -> 0.0;
special_day_factor(2,1) -> 0.3;
special_day_factor(_,_) -> 1.

hour_factor(7) -> 0.1;
hour_factor(8) -> 0.1;
hour_factor(9) -> 0.2;
hour_factor(10) -> 0.5;
hour_factor(11) -> 1;
hour_factor(12) -> 1;
hour_factor(13) -> 0.7;
hour_factor(14) -> 0.3;
hour_factor(15) -> 0.1;
hour_factor(16) -> 0.1;
hour_factor(_) -> 0.

% Kiedy wydaja prace dyplomowe ?
month_factor(3) -> 2;
month_factor(2) -> 0.4;
month_factor(7) -> 0.1;
month_factor(8) -> 0.1;
month_factor(9) -> 2;
month_factor(_) -> 1.