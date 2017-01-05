-module(constants).

-compile([export_all]).

second() -> 1000.
minute() -> second() * 60.
hour() -> minute() * 60.
day() -> hour() * 24.
week() -> day() * 7.
month() -> day() * 30.

% Base is second (minute per second).
% Then 10x faster is second() / 10 so timeUnit is 10 minutes per seconds
timeUnit() -> round(second() / 10).
