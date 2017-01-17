#!/usr/bin/env escript
%%! -noinput -pa ../src/ebin +A 50
-include_lib("src/include/cecho.hrl").
main(_) -> dziekanat:main(300000,poniedzialek,40,30,6,18,1,2016).
