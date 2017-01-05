-module(customTimer).

-compile([export_all]).

-import(constants, [timeUnit/0]).

customTimerThread(DIW,S,M,H,D,Mo,Y) ->
  receive
    go ->
      NS = countSecond(S+1),
      NM = countMinute(M,S+1),
      NH = countHour(H,NM),
      ND = countDay(D,NH),
      NDIW = countDayInWeek(D,ND,DIW),
      NMo = countMonth(Mo,ND),
      NY = countYear(Y,NMo),
      customTimerThread(NDIW, NS, countMinute(NM), countHour(NH), countDay(ND), countMonth(NMo), NY);
    {From, get_time} -> From ! {DIW,S,M,H,D,Mo,Y}, customTimerThread(DIW,S,M,H,D,Mo,Y)
end.

customTimer({DayInWeek,Second,Minute,Hour,Day,Month,Year}) ->
  NewSecond = countSecond(Second+1),
  NewMinute = countMinute(Minute,Second+1),
  NewHour = countHour(Hour,NewMinute),
  NewDay = countDay(Day,NewHour),
  NewDayInWeek = countDayInWeek(Day,NewDay,DayInWeek),
  NewMonth = countMonth(Month,NewDay),
  NewYear = countYear(Year,NewMonth),
  {NewDayInWeek, NewSecond, countMinute(NewMinute), countHour(NewHour), countDay(NewDay), countMonth(NewMonth), NewYear}
.

customTimer2(DIW,S,M,H,D,Mo,Y) ->
  io:format("~B ~B ~B ~B ~B ~B ~n",[S,M,H,D,Mo,Y]),
  timer:sleep(round(timeUnit()/1000)),
  NS = countSecond(S+1),
  io:format(":) ~n"),
  NM = countMinute(M,S+1),
  show(M,NM,H,D,Mo,Y),
  io:format("2 :) ~n"),
  NH = countHour(H,NM),
  io:format("3 :) ~n"),
  ND = countDay(D,NH),
  io:format("4 :) ~n"),
  NDIW = countDayInWeek(D,ND,DIW),
  io:format("5 :) ~B ~B ~n",[Mo,ND]),
  NMo = countMonth(Mo,ND),
  io:format("6 :) ~n"),
  NY = countYear(Y,NMo),
  io:format("7 :) ~n"),
  customTimer(
    NDIW,
    NS,
    countMinute(NM),
    countHour(NH),
    countDay(ND),
    countMonth(NMo),
    NY)
.
show(M,M,_,_,_,_) -> 1;
show(M,_,H,D,Mo,Y) -> io:format("~B ~B ~B ~B ~B ~n",[M,H,D,Mo,Y]).

nextDay(poniedzialek) -> wtorek;
nextDay(wtorek) -> sroda;
nextDay(sroda) -> czwartek;
nextDay(czwartek) -> piatek;
nextDay(piatek) -> sobota;
nextDay(sobota) -> niedziela;
nextDay(niedziela) -> poniedzialek.

countDayInWeek(X,X,DIW) -> DIW;
countDayInWeek(_,_,DIW) -> nextDay(DIW).

countSecond(60) -> 0;
countSecond(S) -> S.

countMinute(60) -> 0;
countMinute(M) -> M.

countHour(24) -> 0;
countHour(H) -> H.

countDay(31) -> 0;
countDay(D) -> D.

countMonth(13) -> 0;
countMonth(M) -> M.

countMinute(M,60) -> M+1;
countMinute(M,_) -> M.

countHour(H,60) -> H+1;
countHour(H,_) -> H.

countDay(D,24) -> D+1;
countDay(D,_) -> D.

countMonth(M,31) -> M+1;
countMonth(M,_) -> M.

countYear(Y,13) -> Y+1;
countYear(Y,_) -> Y.