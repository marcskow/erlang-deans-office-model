-module(obsluga).

%% API
-export([getTicket/4, student/7, secretary/4,screen/4,getStudentSecretary/2]).

-import(dataGenerator, [generateStudent/0,toString/1,generateInteger/2,generateFieldOfStudy/0]).
-import(dziekanat,[getSecretary/2]).

waitIntoQueue() -> timer:sleep(10 * constants:timeUnit()).
handleStudent() -> timer:sleep(10 * constants:timeUnit()).
thinkABit() -> timer:sleep(constants:timeUnit()).

printHandleStudentMessage(FoS, Num) -> io:format(lists:concat(
  ["Pani z dziekanatu ", toString(FoS), ". Rozpoczynam obslugiwac studenta nr ~B. ~n"]
),[Num]).
printGoodByMessage(SFoS,SNum) -> io:format(lists:concat(
  ["Do studenta nr ~B z: ", toString(SFoS)," - Dobrze, to wszystko moze pan odejsc. ~n"]
),[SNum]).
printResponse(Response,Message) -> io:format(lists:concat([Response,Message])).


student(FieldOfStudy,Issue,Screen,SecretaryList,TicketMachine,Clock,Ticket) ->
  receive
    go -> TicketMachine ! {self(), FieldOfStudy},
      student(FieldOfStudy,Issue,Screen,SecretaryList,TicketMachine,Clock,Ticket);
    {ticket, P} ->
      io:format("Dostalem numerek ~B ~n",[P]),
      Screen ! {self(), FieldOfStudy, number},
      student(FieldOfStudy,Issue,Screen,SecretaryList,TicketMachine,Clock,P);
    {number, N} ->
      if Ticket =/= N ->
        io:format("Musze poczekac... ~B ~B ~n", [Ticket, N]),
        waitIntoQueue(),
        Screen ! {self(), FieldOfStudy, number},
        student(FieldOfStudy,Issue,Screen,SecretaryList,TicketMachine,Clock,Ticket);
        Ticket =:= N ->
          io:format("Moge wchodzic, dzien dobry ! ~n"),
          Secretary = getStudentSecretary(SecretaryList,FieldOfStudy),
          Secretary ! {self(), FieldOfStudy, Ticket}, student(FieldOfStudy,Issue,Screen,SecretaryList,TicketMachine,Clock,Ticket)
      end;
    {wait_for_your_turn, Response} ->
      printResponse(Response,". Musze jeszcze poczekac... ~n"),
      waitIntoQueue(),
      Secretary = getStudentSecretary(SecretaryList,FieldOfStudy),
      Secretary ! {self(), FieldOfStudy, Ticket},
      student(FieldOfStudy,Issue,Screen,SecretaryList,TicketMachine,Clock,Ticket);
    not_your_secretary ->
      io:format("Musze jeszcze raz pomyslec czy poszedlem do odpowiedniej osoby... ~n"),
      thinkABit(),
      Secretary = getStudentSecretary(SecretaryList,FieldOfStudy),
      Secretary ! {self(), FieldOfStudy, Ticket}, student(FieldOfStudy,Issue,Screen,SecretaryList,TicketMachine,Clock,Ticket);
      terminate -> ok
  end.

getStudentSecretary(SecretaryList,FieldOfStudy) ->
  getSecretary(studentTryToRecognizeHisSecretary(generateInteger(5,7),FieldOfStudy),SecretaryList).

studentTryToRecognizeHisSecretary(6,_) -> generateFieldOfStudy();
studentTryToRecognizeHisSecretary(_,FieldOfStudy) -> FieldOfStudy.

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


secretary(FieldOfStudy, Screen, Clock, NumberToHandle) ->
  receive
    {From, StudentFieldOfStudy, StudentNumber} ->
      if StudentFieldOfStudy =/= FieldOfStudy ->
        io:format("Nie wiesz z jakiego jestes kierunku!? ~n"),
        From ! not_your_secretary,
        secretary(FieldOfStudy,Screen, Clock, NumberToHandle);
        StudentFieldOfStudy =:= FieldOfStudy ->
          if StudentNumber =/= NumberToHandle -> From ! {wait_for_your_turn,"Poczekaj na swoją kolej! ~n"};
           StudentNumber =:= NumberToHandle ->
           printHandleStudentMessage(StudentFieldOfStudy,StudentNumber),
           handleStudent(),
           printGoodByMessage(StudentFieldOfStudy,StudentNumber),
           From ! {terminate},
           Screen ! {FieldOfStudy, NumberToHandle + 1},
           secretary(FieldOfStudy,Screen, Clock, NumberToHandle + 1)
         end
      end
  end.