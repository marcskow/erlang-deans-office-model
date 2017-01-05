-module(dataGenerator).

-export([generateFieldOfStudy/0,toString/1,generate/1, generateInteger/2]).

-import(obsluga,[student/1]).

generateFieldOfStudy() ->
  N = generateInteger(0,3),
  FieldOfStudy = assignFieldOfStudy(N),
  FieldOfStudy.

assignFieldOfStudy(0) -> automatyka;
assignFieldOfStudy(1) -> elektrotechnika;
assignFieldOfStudy(2) -> informatyka;
assignFieldOfStudy(3) -> biomedyczna.

toString(automatyka) -> "Automatyka i Robotyka";
toString(informatyka) -> "Informatyka";
toString(biomedyczna) -> "Inzynieria Biomedyczna";
toString(elektrotechnika) -> "Elektrotechnika".

generate(0) -> io:fwrite("~n");
generate(N) ->
  A = generateInteger(0,4),
  io:fwrite("~B~n",[A]),
  generate(N-1).

generateInteger(From, To) ->
  round((random:uniform() * (To - From) + From)).

getCurrentTime() ->
  {date(),time()}.