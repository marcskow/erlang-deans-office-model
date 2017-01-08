
%%%-------------------------------------------------------------------
-module(deansView).
-compile(export_all).

-include("cecho.hrl").
-define(WINODW_SIZE_X, 140).
-define(WINODW_SIZE_Y, 50).
-define(WINDOW_FRAME_CHAR,$*).
-import(dataGenerator,[toString/1]).
%% API
-export([]).

input_reader() ->
  P = cecho:getch(),
  action(P),
  input_reader().

action($q)->
  application:stop(cecho),
  halt();
action(_)->
  ok.

initView()->
  application:start(cecho),
  ok = cecho:cbreak(),
  ok = cecho:noecho(),
  ok = cecho:curs_set(?ceCURS_INVISIBLE),
  ok = cecho:start_color(),
  ok = cecho:init_pair(1, ?ceCOLOR_BLACK, ?ceCOLOR_RED),
  ok = cecho:init_pair(2, ?ceCOLOR_BLACK, ?ceCOLOR_GREEN),
  ok = cecho:init_pair(3, ?ceCOLOR_BLACK, ?ceCOLOR_YELLOW),
  ok = cecho:init_pair(4, ?ceCOLOR_BLACK, ?ceCOLOR_BLUE),
  ok = cecho:init_pair(5, ?ceCOLOR_BLACK, ?ceCOLOR_MAGENTA),
  ok = cecho:init_pair(6, ?ceCOLOR_BLACK, ?ceCOLOR_CYAN),
  ok = cecho:init_pair(7, ?ceCOLOR_BLACK, ?ceCOLOR_WHITE),
  ok = cecho:init_pair(8, ?ceCOLOR_BLACK, ?ceCOLOR_BLACK),
  clear(),
  printWindow(7).
%%  printTimer(1,2,3,4,5,6,2016).
%%//  timer:sleep(2000*6)
%%  application:stop(cecho)
%%
printTimer(S,M,H,D,Mo,Y) ->
  printPrettySpace(1,119,20,4),
  printPrettySpace(3,119,20,4),
  cecho:attron(?ceCOLOR_PAIR(7)),
  cecho:mvaddstr(2, 120, io_lib:format("~2..0B:~2..0B:~2..0B ~2..0B-~2..0B-~4.B",[H,M,S,D,Mo,Y])),
  printPrettySpace(2,119,0,4),
  printPrettySpace(2,139,0,4),
  cecho:refresh().

viewThread()->
  viewThread(0).

viewThread(NumberOfStudentsMessage)->
  receive
    {clock,S,M,H,D,Mo,Y} ->
      printTimer(S,M,H,D,Mo,Y),
      viewThread(NumberOfStudentsMessage);
    {ticket,E,A,I,IB} ->
      printTicketNumber(E,A,I,IB,?WINODW_SIZE_Y-8),
      viewThread(NumberOfStudentsMessage);
    {actual_ticket,FoS,Number} ->
      printNextStudent(FoS,Number),
      viewThread(NumberOfStudentsMessage);
    {say_no_more,FoS,Number}->
      printGoodByeMessage(FoS,Number),
      viewThread(NumberOfStudentsMessage);
    {secretary_break_time,FoS}->
      printBreak(FoS),
      viewThread(NumberOfStudentsMessage);
    {go_to_dean,FoS}->
      goToDean(FoS),
      viewThread(NumberOfStudentsMessage);
    {dean_welcome,TicketNumber,FieldOfStudy}->
      printDeanWelcome(FieldOfStudy,TicketNumber),
      viewThread(NumberOfStudentsMessage);
    {dean_message,Type,FoS}->
      printDeanMessage(Type),
      viewThread(NumberOfStudentsMessage);
    {student_message,FoS,Message}->
     Actual = printStudentMessage(FoS,Message,NumberOfStudentsMessage),
    viewThread(Actual rem 18)
  end.






printPrettySpace(Height,From,Length,Color) ->
  printPrettyChar(Height,From,Length,Color,$ ).



printPrettyChar(Height,From,Length,Color,Char) when Length == 0 ->
  cecho:move(Height,From+Length),
  cecho:attron(?ceCOLOR_PAIR(Color)),
  cecho:refresh(),
  cecho:addch(Char);
printPrettyChar(Heigh,From,Length,Color,Char) ->
  cecho:move(Heigh,From+Length),
  cecho:attron(?ceCOLOR_PAIR(Color)),
  cecho:addch(Char),
  cecho:refresh(),
  printPrettyChar(Heigh,From,Length-1,Color,Char).

clear()->
  clear(?WINODW_SIZE_Y).
clear(Line) when Line == 0 ->
  printPrettyChar(Line,0,?WINODW_SIZE_X,8,$ );
clear(Line)->
  printPrettyChar(Line,0,?WINODW_SIZE_X,8,$ ),
  clear(Line-1).

printWindow(Color)->
  printPrettyChar(0,0,?WINODW_SIZE_X,Color,?WINDOW_FRAME_CHAR),
  printWindow(Color,1).
printWindow(Color,Height) when Height+1 == ?WINODW_SIZE_Y ->
  printPrettyChar(Height,0,?WINODW_SIZE_X,Color,?WINDOW_FRAME_CHAR),
  cecho:move(?WINODW_SIZE_Y,0),
  cecho:addstr("Wpisz q aby wyjsc z programu"),
  printDeansOfficeName(),
  printDean(),
  printDeanOfficeScreen(),
  printSecretary(),
  printTicketNumber(1,1,1,1,?WINODW_SIZE_Y-8),
  printTicketNumber(0,0,0,0,?WINODW_SIZE_Y-4),
  cecho:refresh();

printWindow(Color,Height) ->
  cecho:move(Height,0),
  cecho:attron(?ceCOLOR_PAIR(Color)),
  cecho:refresh(),
  cecho:addch(?WINDOW_FRAME_CHAR),
  cecho:move(Height,?WINODW_SIZE_X),
  cecho:attron(?ceCOLOR_PAIR(Color)),
  cecho:refresh(),
  cecho:addch(?WINDOW_FRAME_CHAR),
  printWindow(Color,Height+1).

printSecretary()->
  printPrettySpace(8,1,?WINODW_SIZE_X-2,7),
  printPrettySpace(10,1,?WINODW_SIZE_X-2,7),
  printPrettySpace(9,1,?WINODW_SIZE_X-2,7),
  printSecretary("Elektrotechnika",9,1),
  printSecretary("Automatyka",9,35),
  printSecretary("Informatyka",9,69),
  printSecretary("BioMed",9,104).






printSecretary(Name,Height,Where) ->
  cecho:attron(?ceCOLOR_PAIR(7)),
  cecho:mvaddstr(Height,Where,io_lib:format("~20.s",[Name])),
  cecho:refresh().

printDeansOfficeName()->
  cecho:attron(?ceCOLOR_PAIR(1)),
  cecho:mvaddstr(1,1," _____      _      _                     _   "),
  cecho:refresh(),
  cecho:mvaddstr(2,1,"|  __ \\    (_)    | |                   | |  "),
  cecho:refresh(),
  cecho:mvaddstr(3,1,"| |  | |_____  ___| | ____ _ _ __   __ _| |_ "),
  cecho:refresh(),
  cecho:mvaddstr(4,1,"| |  | |_  / |/ _ \\ |/ / _` | '_ \\ / _` | __|"),
  cecho:refresh(),
  cecho:mvaddstr(5,1,"| |__| |/ /| |  __/   < (_| | | | | (_| | |_ "),
  cecho:refresh(),
  cecho:mvaddstr(6,1,"|_____//___|_|\\___|_|\\_\\__,_|_| |_|\\__,_|\\__|"),
  cecho:mvaddstr(7,1,"                                             "),
  cecho:refresh().

printDean()->
  cecho:attron(?ceCOLOR_PAIR(1)),
  cecho:mvaddstr(20,1," _____              _____      _      _               "),
  cecho:refresh(),
  cecho:mvaddstr(21,1,"|  __ \\            |  __ \\    (_)    | |              "),
  cecho:refresh(),
  cecho:mvaddstr(22,1,"| |__) |_ _ _ __   | |  | |_____  ___| | ____ _ _ __  "),
  cecho:refresh(),
  cecho:mvaddstr(23,1,"|  ___/ _` | '_ \\  | |  | |_  / |/ _ \\ |/ / _` | '_ \\ "),
  cecho:refresh(),
  cecho:mvaddstr(24,1,"| |  | (_| | | | | | |__| |/ /| |  __/   < (_| | | | |"),
  cecho:refresh(),
  cecho:mvaddstr(25,1,"|_|   \\__,_|_| |_| |_____//___|_|\\___|_|\\_\\__,_|_| |_|"),
  cecho:mvaddstr(26,1,"                                                      "),
  cecho:refresh().

printDeanOfficeScreen()->
  printPrettyChar(?WINODW_SIZE_Y-12,1,50,5,$-),
  printDeanOfficeScreen(11).

printDeanOfficeScreen(LineNumber) when LineNumber == 2 ->
  printPrettyChar(?WINODW_SIZE_Y-2,1,50,5,$-),
  cecho:attron(?ceCOLOR_PAIR(6)),
  cecho:mvaddstr(?WINODW_SIZE_Y-8,2,"Kolejka:"),
  cecho:mvaddstr(?WINODW_SIZE_Y-4,2,"Akt:"),
  printSecretaryShortName("E",?WINODW_SIZE_Y-10,8),
  printSecretaryShortName("A",?WINODW_SIZE_Y-10,19),
  printSecretaryShortName("I",?WINODW_SIZE_Y-10,29),
  printSecretaryShortName("IB",?WINODW_SIZE_Y-10,39);
printDeanOfficeScreen(LineNumber) ->
  printPrettyChar(?WINODW_SIZE_Y-LineNumber,2,49,4,$ ),
  cecho:attron(?ceCOLOR_PAIR(5)),
  cecho:mvaddch(?WINODW_SIZE_Y-LineNumber,1,$|),
  cecho:mvaddch(?WINODW_SIZE_Y-LineNumber,51,$|),
  printDeanOfficeScreen(LineNumber-1).



printSecretaryShortName(Name,Height,Where) ->
  cecho:attron(?ceCOLOR_PAIR(4)),
  cecho:mvaddstr(Height,Where,io_lib:format("~8.s",[Name])),
  cecho:refresh().

printTicketNumber(E,A,I,IB,Height) ->
  cecho:attron(?ceCOLOR_PAIR(7)),
  cecho:mvaddstr(Height,15,io_lib:format("~B",[E])),
  cecho:mvaddstr(Height,26,io_lib:format("~B",[A])),
  cecho:mvaddstr(Height,36,io_lib:format("~B",[I])),
  cecho:mvaddstr(Height,45,io_lib:format("~B",[IB])),
  cecho:refresh().

printNextStudent(elektrotechnika,Number)->
  cecho:attron(?ceCOLOR_PAIR(7)),
  cecho:mvaddstr(11,1,io_lib:format("Prosze podejsc nr: ~B",[Number])),
  cecho:attron(?ceCOLOR_PAIR(5)),
  cecho:mvaddstr(?WINODW_SIZE_Y-4,15,io_lib:format("~B",[Number])),
  cecho:refresh();
printNextStudent(automatyka,Number)->
  cecho:attron(?ceCOLOR_PAIR(7)),
  cecho:mvaddstr(11,44,io_lib:format("Prosze podejsc nr: ~B",[Number])),
  cecho:attron(?ceCOLOR_PAIR(5)),
  cecho:mvaddstr(?WINODW_SIZE_Y-4,26,io_lib:format("~B",[Number])),
  cecho:refresh();
printNextStudent(informatyka,Number)->
  cecho:attron(?ceCOLOR_PAIR(7)),
  cecho:mvaddstr(11,77,io_lib:format("Prosze podejsc nr: ~B",[Number])),
  cecho:attron(?ceCOLOR_PAIR(5)),
  cecho:mvaddstr(?WINODW_SIZE_Y-4,36,io_lib:format("~B",[Number])),
  cecho:refresh();
printNextStudent(biomedyczna,Number)->
  cecho:attron(?ceCOLOR_PAIR(7)),
  cecho:mvaddstr(11,114,io_lib:format("Prosze podejsc nr: ~B",[Number])),
  cecho:attron(?ceCOLOR_PAIR(5)),
  cecho:mvaddstr(?WINODW_SIZE_Y-4,45,io_lib:format("~B",[Number])),
  cecho:refresh().

printGoodByeMessage(elektrotechnika,Number)->
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(13,1,io_lib:format("Zegnam psa z numerem ~B",[Number])),
  cecho:refresh();
printGoodByeMessage(automatyka,Number)->
    cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(13,44,io_lib:format("Zegnam psa z numerem ~B",[Number])),
  cecho:refresh();
printGoodByeMessage(informatyka,Number)->
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(13,77,io_lib:format("Zegnam psa z numerem ~B",[Number])),
  cecho:refresh();
printGoodByeMessage(biomedyczna,Number)->
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(13,114,io_lib:format("Zegnam psa z numerem ~B",[Number])),
  cecho:refresh().



printBreak(elektrotechnika)->
  printPrettyChar(11,1,30,8,$ ),
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(11,1,"Teraz kawa"),
  cecho:refresh();
printBreak(automatyka)->
  printPrettyChar(11,44,30,8,$ ),
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(11,44,"Teraz kawa"),
  cecho:refresh();
printBreak(informatyka)->
  printPrettyChar(11,77,30,8,$ ),
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(11,77,"Teraz kawa"),
  cecho:refresh();
printBreak(biomedyczna)->
  printPrettyChar(11,114,24,8,$ ),
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(11,114,"Teraz kawa"),
  cecho:refresh().

goToDean(elektrotechnika)->
  printPrettyChar(13,1,30,8,$ ),
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(13,1,"Do dziekana szmato"),
  cecho:refresh();
goToDean(automatyka)->
  printPrettyChar(13,44,30,8,$ ),
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(13,44,"Do dziekana szmato"),
  cecho:refresh();
goToDean(informatyka)->
  printPrettyChar(13,77,30,8,$ ),
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(13,77,"Do dziekana szmato"),
  cecho:refresh();
goToDean(biomedyczna)->
  printPrettyChar(13,114,24,8,$ ),
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(13,114,"Do dziekana szmato"),
  cecho:refresh().


printDeanWelcome(FieldOfStudy,TicketNumber) ->
  printPrettyChar(22,60,70,8,$ ),
%%  printPrettyChar(24,60,70,8,$ ),
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(22,60,io_lib:format("Witam psa z ~s z nr ~B",[FieldOfStudy,TicketNumber])),
  cecho:refresh().

printDeanMessage(Type)->
%%  printPrettyChar(22,60,70,8,$ ),
  printPrettyChar(24,60,70,8,$ ),
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(24,60,getDeanMessage(Type)),
  cecho:refresh().

getDeanMessage(dean_reallybad)->
  "Jak ty mowisz to dziekana dziwko";
getDeanMessage(dean_bad)->
  "Nie pomoge Ci w tej sprawie";
getDeanMessage(dean_ok)->
  "Dobra podpisze Ci to";
getDeanMessage(againToSecretary)->
  "Musisz jeszcze wrocic do Pani z dziakanatu";
getDeanMessage(_)->
  "Spokojnie cos sie wymysli".
printStudentMessage(FoS,Message,Number) ->
  printPrettyChar(30+Number,60,79,8,$ ),
  cecho:attron(?ceCOLOR_PAIR(3)),
  cecho:mvaddstr(30+Number,60,io_lib:format("Student z  ~s: ~s ",[toString(FoS),getStudentMessage(Message)])),
  cecho:refresh(),
  Number+1.

getStudentMessage(to_dean) ->
  "Musze isc do dziekana";
getStudentMessage(break_time) ->
  "Widze ze jest przerwa";
getStudentMessage(dean_ok) ->
  "Dziekan podpisal";
getStudentMessage(dean_bad) ->
  "Pan dziekan nie pomogl";
getStudentMessage(dean_reallybad) ->
  "Pan dziekan jest zdenerwowany";
getStudentMessage(againToSecretary) ->
  "Kurcze musze jeszcze razd od sekretariatu";
getStudentMessage(done) ->
  "Gotowe wracam do domu";
getStudentMessage(_)->
  "A niewazne".


