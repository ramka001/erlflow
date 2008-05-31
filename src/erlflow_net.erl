-module(erlflow_net).
-include("/opt/local/lib/erlang/lib/xmerl-1.1.8/include/xmerl.hrl").

-export([network/2,netsuper/1,place/5,transition/4]).


place(ID, Name, Inputs, Outputs, Tokens) ->
    receive
        {add_token, Token} ->
            io:format("token received: ~s ~n", [Token]),
            NewTokens = lists:append(Tokens, [Token]),
            place(ID, Name, Inputs, Outputs, NewTokens);
        {consume_token, TransitionPid, TokenId} ->
            io:format("~p is consuming token: ~p~n", [ID, TokenId]),
            Bool = lists:any(fun(X) -> X == TokenId end, Tokens),
            if 
                Bool ->
                    TransitionPid ! {token_consumed, TokenId},       
                    NewTokens = lists:delete(TokenId, Tokens),
                    place(ID, Name, Inputs, Outputs, NewTokens);
                Bool == false ->
                    io:format("~p doesn't have token ~p ~n", [ID, TokenId]),
                    place(ID, Name, Inputs, Outputs, Tokens)
            end;
        {input, Source} ->
            io:format("~p has a new input arc from ~p ~n", [ID, Source]),
            NewInputs = lists:append(Inputs, [Source]),
            place(ID, Name, NewInputs, Outputs, Tokens);
        {output, Target} ->
            io:format("~p has a new output arc to ~p ~n", [ID, Target]),
            NewOutputs = lists:append(Outputs, [Target]),
            place(ID, Name, Inputs, NewOutputs, Tokens);
        {status, From} ->
            io:format("status requested by ~p ~n", [From]),
            io:format("status:~nID:~p~nName:~p~nInputs:~p~nOutputs:~p~nTokens:~p~n", [ID, Name, Inputs, Outputs, Tokens]),
            From ! {status, [ID, Name, Inputs, Outputs, Tokens]},
            place(ID, Name, Inputs, Outputs, Tokens);
        {transitions, From} ->
            From ! {transitions, [Outputs]},
            io:format("forward transitions = ~p~n", [Outputs]),
            place(ID, Name, Inputs, Outputs, Tokens);
        Other ->  
            io:format("Received:~p~n", [Other]),
            place(ID, Name, Inputs, Outputs, Tokens)
    end.

transition(ID, Name, Inputs, Outputs) ->
    receive
        {execute, TokenId} ->
            io:format("~p is executing token: ~p~n", [ID, TokenId]),
            lists:foreach(fun(X) -> X ! {consume_token, self(), TokenId} end, Inputs),
            transition(ID, Name, Inputs, Outputs);
        {token_consumed, TokenId} ->
            io:format("~p knows that token: ~p has been consumed~n", [ID, TokenId]),
            lists:foreach(fun(X) -> X ! {add_token, TokenId} end, Outputs), %%TODO: Actually this produce tokens in all outputs places, this is wrong accoring to theory.
            transition(ID, Name, Inputs, Outputs);
        {input, Source} ->
            io:format("~p has a new input arc from ~p ~n", [ID, Source]),
            NewInputs = lists:append(Inputs, [Source]),
            transition(ID, Name, NewInputs, Outputs);
        {output, Target} ->
            io:format("~p has a new output arc to ~p ~n", [ID, Target]),
            NewOutputs = lists:append(Outputs, [Target]),
            transition(ID, Name, Inputs, NewOutputs);
        {status, From} ->
            io:format("status requested by ~p ~n", [From]),
            io:format("status:~nName:~p~nInputs:~p~nOutputs:~p~n", [Name, Inputs, Outputs]),
            From ! {status, Name, Inputs, Outputs},
            transition(ID, Name, Inputs, Outputs);
        {places, From} ->
            From ! {places, [Outputs]},
            io:format("forward places = ~p~n", [Outputs]),
            transition(ID, Name, Inputs, Outputs);
        Other ->  
            io:format("Received:~p~n", [Other]),
            transition(ID, Name, Inputs, Outputs)
    end.

network(Places, Transitions) ->
    receive
        {add_place, ID, Name} ->
            register(ID, spawn(erlflow_net, place, [ID,Name,[],[],[]])),
            NewPlaces = lists:append(Places, [{ID, Name}]),
            io:format("add_place ~p ~n", [NewPlaces]),
            network(NewPlaces, Transitions);
        {add_transition,  ID, Name} ->
            register(ID, spawn(erlflow_net, transition, [ID,Name,[],[]])),
            NewTransitions = lists:append(Transitions, [{ID, Name}]),
            io:format("add_place ~p ~n", [NewTransitions]),
            network(Places, NewTransitions);
        {get_status, From} ->
            From ! [Places, Transitions],
            io:format("status of net is: places=~p transitions=~p ~n", [Places, Transitions]),
            network(Places, Transitions);
        {status, State} ->
            io:format("status of ~w is: ~w inputs, ~w outputs, ~w tokens.~n", State),
            network(Places, Transitions);
        _else ->
            io:format("network Received:~p~n", [_else]),
            network(Places, Transitions)
    end.

netsuper(Networks) ->
    receive
        {add_net, ID, Name} ->
            io:format("add_network ~p ~n", [ID]),
            NewNetworks = lists:append(Networks, {atom_to_list(ID),Name}),
            register(ID, spawn(erlflow_net, network, [[],[]])),
            netsuper(NewNetworks);
        {get_status, From} ->
            From ! Networks,
            io:format("status of net is: networks =~p ~n", [Networks]),
            netsuper(Networks);
        _else ->
            io:format("Received:~p~n", [_else]),
            netsuper(Networks)
    end.



