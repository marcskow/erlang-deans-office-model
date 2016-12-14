-module(obsluga).

%% API
-export([getTicket/5, student/1, secretary/2,screen/5]).

-import(dataGenerator, [generateStudent/0,toString/1]).

% student ( kierunek
student(FoS) ->
  receive
    {ticket, T} ->
      io:fwrite("Dostalem numerek ~B ~n",[T])
  end.

screen(E,A,I,IB,M) ->
  receive
    {From, elektrotechnika, number} -> From ! E;
    {From, automatyka, number} -> From ! A;
    {From, informatyka, number} -> From ! I;
    {From, biomedyczna, number} -> From ! IB;
    {From, mikroelektronika, number} -> From ! M;
    {elektrotechnika, N} -> screen(N,A,I,IB,M);
    {automatyka, N} -> screen(E,N,I,IB,M);
    {informatyka,N} -> screen(E,A,N,IB,M);
    {biomedyczna,N} -> screen(E,A,I,N,M);
    {mikroelektronika,N} -> screen(E,A,I,IB,M)
  end.

% automat do bilecikow ( liczniki ele aut inf inzbio mikro
getTicket(E,A,I,IB,M) ->
  receive
    {From, elektrotechnika} ->
      From ! {ticket, E},
      getTicket(E+1,A,I,IB,M);
    {From, automatyka} ->
      From ! {ticket, A},
      getTicket(E,A+1,I,IB,M);
    {From, informatyka} ->
      From ! {ticket, I},
      getTicket(E,A,I+1,IB,M);
    {From, biomedyczna} ->
      From ! {ticket, IB},
      getTicket(E,A,I,IB+1,M);
    {From, mikroelektronika} ->
      From ! {ticket, M},
      getTicket(E,A,I,IB,M+1);
    terminate -> ok;
    _ -> not_found
  end.

% secretary ( kierunek ktory obsluguje, numerek do nastepnej obslugi
secretary(FoS, Num) ->
  receive
    {From, SFoS, SNum} ->
      if SNum =/= Num -> From ! {not_ok,"Poczekaj na swoją kolej!"};
         SNum =:= Num ->
           io:fwrite(toString(SFoS)),
           io:fwrite(". Rozpoczynam obslugiwac studenta ~B ~n",[Num]),
           timer:sleep(10000),
           From ! {ok}
      end
  end.