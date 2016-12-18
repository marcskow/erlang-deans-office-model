-module(obsluga).

%% API
-export([getTicket/4, student/4, secretary/3,screen/4]).

-import(dataGenerator, [generateStudent/0,toString/1]).

waitIntoQueue() -> timer:sleep(10000).
handleStudent() -> timer:sleep(10000).

printHandleStudentMessage(FoS, Num) -> io:format(lists:concat(
  ["Pani z dziekanatu ", toString(FoS), ". Rozpoczynam obslugiwac studenta nr ~B. ~n"]
),[Num]).
printGoodByMessage(SFoS,SNum) -> io:format(lists:concat(
  ["Do studenta nr ~B z: ", toString(SFoS)," - Dobrze, to wszystko moze pan odejsc. ~n"]
),[SNum]).
printResponse(Response,Message) -> io:format(lists:concat([Response,Message])).


student(FoS,Scr,Sec,T) ->
  receive
    {ticket, P} ->
      io:format("Dostalem numerek ~B ~n",[P]),
      Scr ! {self(), FoS, number},
      student(FoS,Scr,Sec,P);
    {number, N} ->
      if T =/= N -> io:format("Musze poczekac... ~n"), waitIntoQueue(), Scr ! {self(), FoS, number}, student(FoS,Scr,Sec,T);
         T =:= N -> io:format("Moge wchodzic, dzien dobry ! ~n"), Sec ! {self(), FoS, T}, student(FoS,Scr,Sec,T)
      end;
    {not_ok, Response} ->
      printResponse(Response,". Musze jeszcze poczekac... ~n"),
      waitIntoQueue(),
      Sec ! {self(), FoS, T},
      student(FoS,Scr,Sec,T);
    terminate -> ok
  end.

screen(E,A,I,IB) ->
  receive
    {From, elektrotechnika, number} -> From ! {number, E}, screen(E,A,I,IB);
    {From, automatyka, number} -> From ! {number, A}, screen(E,A,I,IB);
    {From, informatyka, number} -> From ! {number, I}, screen(E,A,I,IB);
    {From, biomedyczna, number} -> From ! {number, IB}, screen(E,A,I,IB);
    {elektrotechnika, N} -> screen(N,A,I,IB);
    {automatyka, N} -> screen(E,N,I,IB);
    {informatyka,N} -> screen(E,A,N,IB);
    {biomedyczna,N} -> screen(E,A,I,N)
  end.

getTicket(E,A,I,IB) ->
  receive
    {From, elektrotechnika} ->
      From ! {ticket, E},
      getTicket(E+1,A,I,IB);
    {From, automatyka} ->
      From ! {ticket, A},
      getTicket(E,A+1,I,IB);
    {From, informatyka} ->
      From ! {ticket, I},
      getTicket(E,A,I+1,IB);
    {From, biomedyczna} ->
      From ! {ticket, IB},
      getTicket(E,A,I,IB+1);
    terminate -> ok;
    _ -> not_found
  end.


secretary(FoS, Scr, Num) ->
  receive
    {From, SFoS, SNum} ->
      if SNum =/= Num -> From ! {not_ok,"Poczekaj na swoją kolej! ~n"};
         SNum =:= Num ->
           printHandleStudentMessage(SFoS,SNum),
           handleStudent(),
           printGoodByMessage(SFoS,SNum),
           From ! {terminate},
           Scr ! {FoS, Num + 1},
           secretary(FoS,Scr,Num + 1)
      end
  end.