-module(obsluga).

%% API
-export([getTicket/4, student/4, secretary/3,screen/4]).

-import(dataGenerator, [generateStudent/0,toString/1]).

% student ( kierunek
student(FoS,Scr,Sec,T) ->
  receive
    {ticket, P} ->
      io:format("Dostalem numerek ~B ~n",[P]),
      Scr ! {self(), FoS, number},
      student(FoS,Scr,Sec,P);
    {number, N} ->
      if T =/= N -> io:format("Musze poczekac... ~n"), timer:sleep(10000), Scr ! {self(), FoS, number}, student(FoS,Scr,Sec,T);
         T =:= N -> io:format("Moge wchodzic, dzien dobry ! ~n"), Sec ! {self(), FoS, T}, student(FoS,Scr,Sec,T)
      end;
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

% automat do bilecikow ( liczniki ele aut inf inzbio mikro
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

% secretary ( kierunek ktory obsluguje, numerek do nastepnej obslugi
secretary(FoS, Scr, Num) ->
  receive
    {From, SFoS, SNum} ->
      if SNum =/= Num -> From ! {not_ok,"Poczekaj na swoją kolej! ~n"};
         SNum =:= Num ->
           io:format(lists:concat(["Pani z dziekanatu ", toString(SFoS), ". Rozpoczynam obslugiwac studenta nr ~B. ~n"]),[SNum]),
           timer:sleep(10000),
           io:format(lists:concat(["Do studenta nr ~B z: ", toString(SFoS)," - Dobrze, to wszystko moze pan odejsc. ~n"]),[SNum]),
           From ! {terminate},
           Scr ! {FoS, Num + 1},
           secretary(FoS,Scr,Num + 1)
      end
  end.