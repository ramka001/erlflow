-module(mod1).

-export([start/0, place/0, transition/1]).

place() ->
	io:format("place created~n"),
	done.

transition(Place) ->
	io:format("transition created ~w ~n", [Place]),
	done.

create_places(First | Rest) ->
	spawn(mod1, places, []),
	create_places(Rest).

create_transitions(First | Rest) ->
	spawn(mod1, transition, [First]),
	create_transitions(Rest).


start() ->
	Place = spawn(mod1, place, []),
	Transition = spawn(mod1, transition, [Place]),
	io:format("proceso termina~n", []).
