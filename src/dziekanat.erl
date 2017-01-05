-module(dziekanat).

-import(dataGenerator, [generateFieldOfStudy/0,toString/1,generateInteger/2]).
-import(obsluga,[getTicket/5,student/1,secretary/2,screen/5]).
-import(constants,[timeUnit/0]).
-import(customTimer,[customTimer/1]).

-compile([export_all]).

studentPerTimeUnit() -> 6.

%% API
%-export([]).
%secretary(FoS, Num) ->
%secretary(FoS, Scr, Num) ->
main(NumberOfTimeUnits) ->
  random:seed(erlang:now()),
  Clock = spawn(customTimer, customTimer,[poniedzialek,0,0,6,1,1,2016]),
  TicketMachine = spawn(obsluga, getTicket, [1,1,1,1]),
  Screen = spawn(obsluga,screen,[1,1,1,1]),
  SecretaryList = [spawn(obsluga, secretary, [elektrotechnika,Screen,1]),
    spawn(obsluga,secretary,[automatyka,Screen,1]),
    spawn(obsluga,secretary,[informatyka,Screen,1]),
    spawn(obsluga,secretary,[biomedyczna,Screen,1])],
  start(TicketMachine, SecretaryList, Screen, NumberOfTimeUnits, Clock)
.

start(_,_,_,0,_) -> io:fwrite("");

start(TicketMachine, SecretaryList, Screen, NumberOfTimeUnits, Clock) ->
 % student(FoS,Scr,Sec,T) ->

  FoS = generateFieldOfStudy(),
  Sec = getSecretary(FoS,SecretaryList),

  io:fwrite("Wszedl student kierunku: "),
  io:fwrite(toString(FoS)),
  io:fwrite("~n"),


  Student = spawn(obsluga, student, [FoS, Screen, Sec, -1]),
  timer:sleep(3 * constants:timeUnit()),
  TicketMachine ! {Student, FoS},

  timer:sleep(2 * constants:timeUnit()),

%  NewTime = customTimer(Time),
  Clock ! go,
  start(TicketMachine, SecretaryList, Screen, NumberOfTimeUnits-1, Clock)
.

mainSpawner(SecretaryList, Screen, Clock) ->
  receive
    spawn ->
      Helper = spawn(dziekanat, secondLineSpawner, [SecretaryList, Screen, Clock]),
      Helper ! spawn
  end.

secondLineSpawner(SecretaryList, Screen, Clock) ->
  receive
    spawn ->
      {DayInWeek,_,_,Hour,Day,Month,_} = Time,
      N = studentPerTimeUnit() * week_day_factor(DayInWeek) * special_day_factor(Day,Month) * hour_factor(Hour) * month_factor(Month),
  end.

randomizeTimeout() -> timeUnit() / generateInteger(1,10).

spawner(SL,Scr) ->
  receive
    {spawn} -> ;
  end.




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