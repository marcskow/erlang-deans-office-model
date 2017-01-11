-module(obsluga).

%% API
-export([getTicket/5, student/9, secretary/5,screen/4,getStudentSecretary/2, dean/3]).

-import(dataGenerator, [generateStudent/0,toString/1,generateInteger/2,generateFieldOfStudy/0]).
-import(dziekanat,[getSecretary/2]).

waitIntoQueueTimeout() -> timer:sleep(constants:timeUnit() * 120).
generalIssueTimeout() -> timer:sleep(constants:timeUnit() * 240).
studentCertificateIssueTimeout() -> timer:sleep(constants:timeUnit() * 120).
petitionIssueTimeout() -> timer:sleep(constants:timeUnit() * 60).
socialIssueTimeout() -> timer:sleep(constants:timeUnit() * 140).
degreeIssueTimeout() -> timer:sleep(constants:timeUnit() * 60).
handleStudentTimeout() -> timer:sleep(constants:timeUnit() * 240).
coffeeTimeout() -> timer:sleep(constants:timeUnit() * 240).
thinkABitTimeout() -> timer:sleep(constants:timeUnit() * 120).

printHandleStudentMessage(FoS, Num,View) ->
  View!{actual_ticket,FoS,Num}.
%%  io:format(lists:concat(
%%  ["Pani z dziekanatu ", toString(FoS), ". Rozpoczynam obslugiwac studenta nr ~B. ~n"]
%%),[Num]).
printMessage(Message, SFoS,SNum) ->void.
%%  io:format(lists:concat(
%%  ["Do studenta nr ~B z: ", toString(SFoS),Message]
%%),[SNum]).
printGoodByMessage(SFoS,SNum,View) ->
  View!{say_no_more,SFoS,SNum}.
%%  io:format(lists:concat(
%%  ["Do studenta nr ~B z: ", toString(SFoS)," - Dobrze, to wszystko moze pan odejsc. ~n"]
%%),[SNum]).
printResponse(Response,Message) -> void.
%%  io:format(lists:concat([Response,Message])).


student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket,StudentMessage) ->
  receive
    go -> TicketMachine ! {self(), FieldOfStudy},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket,StudentMessage);
    {ticket, P} ->
%%      io:format("Dostalem numerek ~B ~n",[P]),

      Screen ! {self(), FieldOfStudy, number},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,P,StudentMessage);
    {number, N} ->
      if Ticket =/= N ->
%%        io:format("Musze poczekac... ~B ~B ~n", [Ticket, N]),
        waitIntoQueueTimeout(),
        Screen ! {self(), FieldOfStudy, number},
        student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket,StudentMessage);
        Ticket =:= N ->
%%          io:format("Moge wchodzic, dzien dobry ! ~n"),
          Secretary = getStudentSecretary(SecretaryList,FieldOfStudy),
          Secretary ! {self(), FieldOfStudy, Ticket, Issue},
          student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket,StudentMessage)
      end;
    {wait_for_your_turn, Response} ->
      printResponse(Response,". Musze jeszcze poczekac... ~n"),
      waitIntoQueueTimeout(),
      Secretary = getStudentSecretary(SecretaryList,FieldOfStudy),
      Secretary ! {self(), FieldOfStudy, Ticket, Issue},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket,StudentMessage);
    to_dean ->
      StudentMessage!{student_message,FieldOfStudy,to_dean},
%%      io:format("Musze udac sie z tym do dziekana... ~n"),
      Dean ! {self(), Ticket, FieldOfStudy, Issue},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket,StudentMessage);
    break_time ->
      StudentMessage!{student_message,FieldOfStudy,break_time},
%%      io:format("Musze chwileczke poczekac, Pani robi cos bardzo waznego (kawa)"),
      waitIntoQueueTimeout(),
      Secretary = getSecretary(FieldOfStudy,SecretaryList),
      Secretary ! {self(), FieldOfStudy, Ticket, Issue},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket,StudentMessage);
    {dean_ok, Response} ->
      StudentMessage!{student_message,FieldOfStudy,dean_ok},
      printResponse(Response,". Dziekan mi pomogl, teraz ide do domu ~n");
    {dean_bad, Response} ->
      StudentMessage!{student_message,FieldOfStudy,dean_bad},
      printResponse(Response,". Dziekan nie moze mi w tym pomoc, teraz ide do domu ~n");
    {dean_reallybad, Response} ->
      StudentMessage!{student_message,FieldOfStudy,dean_reallybad},
      printResponse(Response,". Wkurzylem dziekana, powinienem zastanowic sie nad swoim postepowaniem, teraz ide do domu ~n");
    {againToSecretary, Response} ->
      StudentMessage!{student_message,FieldOfStudy,againToSecretary},
      printResponse(Response,". Musze wrocic jeszcze raz do Pani z Dziekanatu ~n"),
      TicketMachine ! {self(), FieldOfStudy},
      student(FieldOfStudy,general,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket,StudentMessage);
    not_your_secretary ->
%%      io:format("Musze jeszcze raz pomyslec czy poszedlem do odpowiedniej osoby... ~n"),
      thinkABitTimeout(),
      Secretary = getStudentSecretary(SecretaryList,FieldOfStudy),
      Secretary ! {self(), FieldOfStudy, Ticket, Issue},
      student(FieldOfStudy,Issue,Screen,SecretaryList,Dean,TicketMachine,Clock,Ticket,StudentMessage);
    {terminate} ->       StudentMessage!{student_message,FieldOfStudy,done}
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

getTicket(E,A,I,IB,View) ->
  receive
    {From, elektrotechnika} ->
      From ! {ticket, E},
      View ! {ticket,E+1,A,I,IB},
      getTicket(E+1,A,I,IB,View);
    {From, automatyka} ->
      From ! {ticket, A},
      View ! {ticket,E,A+1,I,IB},
      getTicket(E,A+1,I,IB,View);
    {From, informatyka} ->
      From ! {ticket, I},
      View ! {ticket,E,A,I+1,IB},
      getTicket(E,A,I+1,IB,View);
    {From, biomedyczna} ->
      From ! {ticket, IB},
      View ! {ticket,E,A,I,IB+1},
      getTicket(E,A,I,IB+1,View);
    terminate -> ok;
    _ -> not_found
  end.

checkOpening(DIW,S,M,H,D,Mo,Y) when DIW =:= poniedzialek; DIW =:= wtorek; DIW =:= sroda; DIW =:= piatek -> checkOpeningByHour(DIW,S,M,H,D,Mo,Y);
checkOpening(DIW,_,_,_,_,_,_) when DIW =:= czwartek; DIW =:= sobota; DIW =:= niedziela -> zamkniete.
checkOpeningByHour(_,_,_,H,_,_,_) when H >= 16, H =< 8 -> zamkniete.

secretary(FieldOfStudy, Screen, Clock, NumberToHandle,View) ->
  receive
    {From, StudentFieldOfStudy, StudentNumber, Issue} ->
      if StudentFieldOfStudy =/= FieldOfStudy ->
%%        io:format("Nie wiesz z jakiego jestes kierunku!? ~n"),
        From ! not_your_secretary,
        secretary(FieldOfStudy,Screen, Clock, NumberToHandle,View);
      StudentFieldOfStudy =:= FieldOfStudy ->
        X = randomizeCoffee(generateInteger(0,10)),
        if X =:= break_time ->
          From ! break_time,
          View ! {secretary_break_time,FieldOfStudy},
          coffeeTimeout(),
          secretary(FieldOfStudy,Screen, Clock, NumberToHandle,View);
          X =:= ok ->
            if StudentNumber =/= NumberToHandle ->
              From ! {wait_for_your_turn,"Poczekaj na swoją kolej! ~n"},
              secretary(FieldOfStudy,Screen, Clock, NumberToHandle,View);
              StudentNumber =:= NumberToHandle ->
              NextNumber = handleStudent(From, Screen, StudentFieldOfStudy, StudentNumber,View, Issue),
              secretary(FieldOfStudy,Screen, Clock, NextNumber,View)
            end
        end
      end
  end.

randomizeCoffee(X) when X >= 0, X =< 2 -> break_time;
randomizeCoffee(X) when X >= 3, X =< 10 -> ok.

handleStudent(From, Screen, FieldOfStudy,TicketNumber,View,general) ->
  printHandleStudentMessage(FieldOfStudy,TicketNumber,View),
  generalIssueTimeout(),
  printGoodByMessage(FieldOfStudy,TicketNumber,View),
  From ! {terminate},
  Screen ! {FieldOfStudy, TicketNumber + 1},
  TicketNumber + 1;
handleStudent(From, Screen, FieldOfStudy,TicketNumber,View,certificate) ->
  printHandleStudentMessage(FieldOfStudy,TicketNumber,View),
  studentCertificateIssueTimeout(),
  printGoodByMessage(FieldOfStudy,TicketNumber,View),
  From ! {terminate},
  Screen ! {FieldOfStudy, TicketNumber + 1},
  TicketNumber + 1;
handleStudent(From, _, FieldOfStudy,TicketNumber,View,degree) ->
  degreeIssueTimeout(),
  View!{go_to_dean,FieldOfStudy,TicketNumber + 1},
%%  printMessage("Musi sie pan udac do dziekana. ~n",FieldOfStudy,TicketNumber),
  From ! to_dean,
  TicketNumber + 1;
handleStudent(From, _, FieldOfStudy,TicketNumber,View,petition) ->
  petitionIssueTimeout(),
  View!{go_to_dean,FieldOfStudy,TicketNumber + 1},
%%  printMessage("Musi sie pan udac do dziekana. ~n",FieldOfStudy,TicketNumber),
  From!to_dean,
  TicketNumber + 1.

dean(Screen, Clock,View) ->
  receive
    {From, TicketNumber, FieldOfStudy, petition} ->
      View!{dean_welcome,TicketNumber,FieldOfStudy},
      petitionIssueTimeout(),
      handlePetition(Screen, From, FieldOfStudy, TicketNumber, generateInteger(0,10),View),
      dean(Screen,Clock,View);
    {From, TicketNumber, FieldOfStudy, degree} ->
      View!{dean_welcome,TicketNumber,FieldOfStudy},
      degreeIssueTimeout(),
      handlePetition(Screen, From, FieldOfStudy, TicketNumber, generateInteger(0,10),View),
      dean(Screen,Clock,View)
  end.

handlePetition(Screen, From, FieldOfStudy, TicketNumber, Random,View) when Random >= 0, Random =< 1 ->
  View!{dean_message,dean_reallybad,FieldOfStudy},
  From ! {dean_reallybad, "Zachowal sie Pan karygodnie, prosze odejsc ! ~n"},
  Screen ! {FieldOfStudy, TicketNumber + 1};
handlePetition(Screen, From, FieldOfStudy, TicketNumber, Random,View) when Random >= 2, Random =< 4 ->
  View!{dean_message,dean_bad},FieldOfStudy,
  From ! {dean_bad, "Nie moge Panu pomoc w tej sprawie ~n"},
  Screen ! {FieldOfStudy, TicketNumber + 1};
handlePetition(Screen, From, FieldOfStudy, TicketNumber, Random,View) when Random >= 5, Random =< 8 ->
  View!{dean_message,dean_ok,FieldOfStudy},
  From ! {dean_ok, "Dobrze, podpisze to panu ~n"},
  Screen ! {FieldOfStudy, TicketNumber + 1};
handlePetition(Screen, From, FieldOfStudy, TicketNumber, Random,View) when Random >= 9, Random =< 10 ->
  View!{dean_message,againToSecretary,FieldOfStudy},
  From ! {againToSecretary, "Musi Pan jeszcze wrocic do Pani z Dziekanatu po jeden papierek ~n"},
  Screen ! {FieldOfStudy, TicketNumber + 1}.

