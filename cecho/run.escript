#!/usr/bin/env escript
%%! -noinput -pa ../cecho/ebin +A 50
-include_lib("cecho/include/cecho.hrl").
main(_) -> dziekanat:main(3000).
