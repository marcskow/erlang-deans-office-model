-module(obsluga).

%% API
-export([getTicket/4, student/8, secretary/4,screen/4,getStudentSecretary/2, dean/2]).

-import(dataGenerator, [generateStudent/0,toString/1,generateInteger/2,generateFieldOfStudy/0]).
-import(dziekanat,[getSecretary/2]).

waitIntoQueueTimeout() -> timer:sleep(10 * constants:timeUnit()).
generalIssueTimeout() -> timer:sleep(10 * constants:timeUnit()).
studentCertificateIssueTimeout() -> timer:sleep(10 * constants:timeUnit()).
petitionIssueTimeout() -> timer:sleep(10 * constants:timeUnit()).
socialIssueTimeout() -> timer:sleep(10 * constants:timeUnit()).
degreeIssueTimeout() -> timer:sleep(10 * constants:timeUnit()).
handleStudentTimeout() -> timer:sleep(10 * constants:timeUnit()).
thinkABitTimeout() -> timer:sleep(constants:timeUnit()).

printHandleStudentMessage(FoS, Num) -> io:format(lists:concat(
  ["Pani z dziekanatu ", toString(FoS), ". Rozpoczynam obslugiwac studenta nr ~B. ~n"]
),[Num]).
printMessage(Message, SFoS,SNum) -> io:format(lists:concat(
  ["Do studenta nr ~B z: ", toString(SFoS),Message]
),[SNum]).
printGoodByMessage(SFoS,SNum) -> io:format(lists:concat(
  ["Do studenta nr ~B z: ", toString(SFoS)," - Dobrze, to wszystko moze pan odejsc. ~n"]
),[SNum]).
printResponse(Response,Message) -> io:format(lists:concat([Response,Message])).


student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket) ->
  receive
    go -> TicketMachine ! {self(), FieldOfStudy},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket);
    {ticket, P} ->
      io:format("Dostalem numerek ~B ~n",[P]),
      Screen ! {self(), FieldOfStudy, number},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,P);
    {number, N} ->
      if Ticket =/= N ->
        io:format("Musze poczekac... ~B ~B ~n", [Ticket, N]),
        waitIntoQueueTimeout(),
        Screen ! {self(), FieldOfStudy, number},
        student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket);
        Ticket =:= N ->
          io:format("Moge wchodzic, dzien dobry ! ~n"),
          Secretary = getStudentSecretary(SecretaryList,FieldOfStudy),
          Secretary ! {self(), FieldOfStudy, Ticket, Issue},
          student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket)
      end;
    {wait_for_your_turn, Response} ->
      printResponse(Response,". Musze jeszcze poczekac... ~n"),
      waitIntoQueueTimeout(),
      Secretary = getStudentSecretary(SecretaryList,FieldOfStudy),
      Secretary ! {self(), FieldOfStudy, Ticket, Issue},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket);
    to_dean ->
      io:format("Musze udac sie z tym do dziekana... ~n"),
      Dean ! {self(), Ticket, FieldOfStudy, Issue},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket);
    break_time ->
      io:format("Musze chwileczke poczekac, Pani robi cos bardzo waznego (kawa)"),
      waitIntoQueueTimeout(),
      Secretary = getSecretary(FieldOfStudy,SecretaryList),
      Secretary ! {self(), FieldOfStudy, Ticket, Issue},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket);
    {dean_ok, Response} ->
      printResponse(Response,". Dziekan mi pomogl, teraz ide do domu ~n");
    {dean_bad, Response} ->
      printResponse(Response,". Dziekan nie moze mi w tym pomoc, teraz ide do domu ~n");
    {dean_reallybad, Response} ->
      printResponse(Response,". Wkurzylem dziekana, powinienem zastanowic sie nad swoim postepowaniem, teraz ide do domu ~n");
    {againToSecretary, Response} ->
      printResponse(Response,". Musze wrocic jeszcze raz do Pani z Dziekanatu ~n"),
      TicketMachine ! {self(), FieldOfStudy},
      student(FieldOfStudy,general,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket);
    not_your_secretary ->
      io:format("Musze jeszcze raz pomyslec czy poszedlem do odpowiedniej osoby... ~n"),
      thinkABitTimeout(),
      Secretary = getStudentSecretary(SecretaryList,FieldOfStudy),
      Secretary ! {self(), FieldOfStudy, Ticket, Issue},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket);
    terminate -> ok
  end.

getStudentSecretary(SecretaryList,FieldOfStudy) ->
  getSecretary(studentTryToRecognizeHisSecretary(generateInteger(5,12),FieldOfStudy),SecretaryList).

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


%{From,_} ->
%Clock ! {self(),get_time};
%{X, DIW,S,M,H,D,Mo,Y} ->
%Y = checkOpening(DIW,S,M,H,D,Mo,Y),
%if Y =:= zamkniete -> X ! zamkniete;
%Y =:= otwarte -> self() ! {otwarte,X,}

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

checkOpening(DIW,S,M,H,D,Mo,Y) when DIW =:= poniedzialek; DIW =:= wtorek; DIW =:= sroda; DIW =:= piatek -> checkOpeningByHour(DIW,S,M,H,D,Mo,Y);
checkOpening(DIW,_,_,_,_,_,_) when DIW =:= czwartek; DIW =:= sobota; DIW =:= niedziela -> zamkniete.
checkOpeningByHour(_,_,_,H,_,_,_) when H >= 16, H =< 8 -> zamkniete.

secretary(FieldOfStudy, Screen, Clock, NumberToHandle) ->
  receive
    {From, StudentFieldOfStudy, StudentNumber, Issue} ->
      if StudentFieldOfStudy =/= FieldOfStudy ->
        io:format("Nie wiesz z jakiego jestes kierunku!? ~n"),
        From ! not_your_secretary,
        secretary(FieldOfStudy,Screen, Clock, NumberToHandle);
      StudentFieldOfStudy =:= FieldOfStudy ->
        X = randomizeCoffee(generateInteger(0,10)),
        if X =:= break_time ->
          From ! break_time,
          secretary(FieldOfStudy,Screen, Clock, NumberToHandle);
          X =:= ok ->
            if StudentNumber =/= NumberToHandle ->
              From ! {wait_for_your_turn,"Poczekaj na swoją kolej! ~n"},
              secretary(FieldOfStudy,Screen, Clock, NumberToHandle);
              StudentNumber =:= NumberToHandle ->
              NextNumber = handleStudent(From, Screen, StudentFieldOfStudy, StudentNumber, Issue),
              secretary(FieldOfStudy,Screen, Clock, NextNumber)
            end
        end
      end
  end.

randomizeCoffee(X) when X >= 0, X =< 2 -> break_time;
randomizeCoffee(X) when X >= 3, X =< 10 -> ok.

handleStudent(From, Screen, FieldOfStudy,TicketNumber,general) ->
  printHandleStudentMessage(FieldOfStudy,TicketNumber),
  generalIssueTimeout(),
  printGoodByMessage(FieldOfStudy,TicketNumber),
  From ! {terminate},
  Screen ! {FieldOfStudy, TicketNumber + 1},
  TicketNumber + 1;
handleStudent(From, Screen, FieldOfStudy,TicketNumber,certificate) ->
  printHandleStudentMessage(FieldOfStudy,TicketNumber),
  studentCertificateIssueTimeout(),
  printGoodByMessage(FieldOfStudy,TicketNumber),
  From ! {terminate},
  Screen ! {FieldOfStudy, TicketNumber + 1},
  TicketNumber + 1;
handleStudent(From, _, FieldOfStudy,TicketNumber,degree) ->
  printMessage("Musi sie pan udac do dziekana. ~n",FieldOfStudy,TicketNumber),
  From ! to_dean,
  TicketNumber + 1;
handleStudent(From, _, FieldOfStudy,TicketNumber,petition) ->
  printMessage("Musi sie pan udac do dziekana. ~n",FieldOfStudy,TicketNumber),
  From ! to_dean,
  TicketNumber + 1.

dean(Screen, Clock) ->
  receive
    {From, TicketNumber, FieldOfStudy, petition} ->
      handlePetition(Screen, From, FieldOfStudy, TicketNumber, generateInteger(0,10)),
      dean(Screen,Clock);
    {From, TicketNumber, FieldOfStudy, degree} ->
      handlePetition(Screen, From, FieldOfStudy, TicketNumber, generateInteger(0,10)),
      dean(Screen,Clock)
  end.

handlePetition(Screen, From, FieldOfStudy, TicketNumber, Random) when Random =:= 0 ->
  From ! {dean_reallybad, "Zachowal sie Pan karygodnie, prosze odejsc ! ~n"},
  Screen ! {FieldOfStudy, TicketNumber + 1};
handlePetition(Screen, From, FieldOfStudy, TicketNumber, Random) when Random >= 1, Random =< 4 ->
  From ! {dean_bad, "Nie moge Panu pomoc w tej sprawie ~n"},
  Screen ! {FieldOfStudy, TicketNumber + 1};
handlePetition(Screen, From, FieldOfStudy, TicketNumber, Random) when Random >= 5, Random =< 8 ->
  From ! {dean_ok, "Dobrze, podpisze to panu ~n"},
  Screen ! {FieldOfStudy, TicketNumber + 1};
handlePetition(Screen, From, FieldOfStudy, TicketNumber, Random) when Random >= 9, Random =< 10 ->
  From ! {againToSecretary, "Musi Pan jeszcze wrocic do Pani z Dziekanatu po jeden papierek ~n"},
  Screen ! {FieldOfStudy, TicketNumber + 1}.

