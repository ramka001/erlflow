-module(erlflow_net).
-include("/opt/local/lib/erlang/lib/xmerl-1.1.8/include/xmerl.hrl").

-export([network/3,netsuper/1,place/5,transition/4]).


place(ID, Name, Inputs, Outputs, Tokens) ->
    receive
        {add_token, Token} ->
            io:format("erlflow_net:place -> token received: ~s ~n", [Token]),
            NewTokens = lists:append(Tokens, [Token]),
            place(ID, Name, Inputs, Outputs, NewTokens);
        {consume_token, TransitionPid, TokenId} ->
            io:format("erlflow_net:place -> ~p is consuming token: ~p~n", [ID, TokenId]),
            Bool = lists:any(fun(X) -> X == TokenId end, Tokens),
            if 
                Bool ->
                    TransitionPid ! {token_consumed, TokenId},       
                    NewTokens = lists:delete(TokenId, Tokens),
                    place(ID, Name, Inputs, Outputs, NewTokens);
                Bool == false ->
                    io:format("erlflow_net:place -> ~p doesn't have token ~p ~n", [ID, TokenId]),
                    place(ID, Name, Inputs, Outputs, Tokens)
            end;
        {input, Source} ->
            io:format("erlflow_net:place -> ~p has a new input arc from ~p ~n", [ID, Source]),
            NewInputs = lists:append(Inputs, [Source]),
            place(ID, Name, NewInputs, Outputs, Tokens);
        {output, Target} ->
            io:format("erlflow_net:place -> ~p has a new output arc to ~p ~n", [ID, Target]),
            NewOutputs = lists:append(Outputs, [Target]),
            place(ID, Name, Inputs, NewOutputs, Tokens);
        {status, From} ->
            io:format("erlflow_net:place -> status requested by ~p ~n", [From]),
            io:format("erlflow_net:place -> status:~nID:~p~nName:~p~nInputs:~p~nOutputs:~p~nTokens:~p~n", [ID, Name, Inputs, Outputs, Tokens]),
            From ! {status, [ID, Name, Inputs, Outputs, Tokens]},
            place(ID, Name, Inputs, Outputs, Tokens);
        {transitions, From} ->
            From ! {transitions, [Outputs]},
            io:format("erlflow_net:place -> forward transitions = ~p~n", [Outputs]),
            place(ID, Name, Inputs, Outputs, Tokens);
        Other ->  
            io:format("erlflow_net:place -> Received:~p~n", [Other]),
            place(ID, Name, Inputs, Outputs, Tokens)
    end.

transition(ID, Name, Inputs, Outputs) ->
    receive
        {execute, TokenId} ->
            io:format("erlflow_net:transition -> ~p is executing token: ~p~n", [ID, TokenId]),
            lists:foreach(fun(X) -> X ! {consume_token, self(), TokenId} end, Inputs),
            transition(ID, Name, Inputs, Outputs);
        {token_consumed, TokenId} ->
            io:format("erlflow_net:transition -> ~p knows that token: ~p has been consumed~n", [ID, TokenId]),
            lists:foreach(fun(X) -> X ! {add_token, TokenId} end, Outputs), %%TODO: Actually this produce tokens in all outputs places, this is wrong accoring to theory.
            transition(ID, Name, Inputs, Outputs);
        {input, Source} ->
            io:format("erlflow_net:transition -> ~p has a new input arc from ~p ~n", [ID, Source]),
            NewInputs = lists:append(Inputs, [Source]),
            transition(ID, Name, NewInputs, Outputs);
        {output, Target} ->
            io:format("erlflow_net:transition -> ~p has a new output arc to ~p ~n", [ID, Target]),
            NewOutputs = lists:append(Outputs, [Target]),
            transition(ID, Name, Inputs, NewOutputs);
        {status, From} ->
            io:format("erlflow_net:transition -> status requested by ~p ~n", [From]),
            io:format("erlflow_net:transition -> status:~nName:~p~nInputs:~p~nOutputs:~p~n", [Name, Inputs, Outputs]),
            From ! {status, Name, Inputs, Outputs},
            transition(ID, Name, Inputs, Outputs);
        {places, From} ->
            From ! {places, [Outputs]},
            io:format("erlflow_net:transition -> forward places = ~p~n", [Outputs]),
            transition(ID, Name, Inputs, Outputs);
        Other ->  
            io:format("erlflow_net:transition -> received:~p~n", [Other]),
            transition(ID, Name, Inputs, Outputs)
    end.

network(Info, Places, Transitions) ->
    receive
        {add_place, ID, Name} ->
            register(ID, spawn(erlflow_net, place, [ID,Name,[],[],[]])),
            NewPlaces = lists:append(Places, [{ID, Name}]),
            io:format("erlflow_net:network -> add_place ~p ~n", [NewPlaces]),
            network(Info, NewPlaces, Transitions);
        {add_transition,  ID, Name} ->
            register(ID, spawn(erlflow_net, transition, [ID,Name,[],[]])),
            NewTransitions = lists:append(Transitions, [{ID, Name}]),
            io:format("erlflow_net:network -> add_place ~p ~n", [NewTransitions]),
            network(Info, Places, NewTransitions);
        {get_status, From} ->
            io:format("erlflow_net:network -> status of net is: info=~p places=~p transitions=~p ~n", [Info, Places, Transitions]),
            From ! [Info, Places, Transitions],
            network(Info, Places, Transitions);
        {status, State} ->
            io:format("erlflow_net:network -> status of ~w is: ~w inputs, ~w outputs, ~w tokens.~n", State),
            network(Info, Places, Transitions);
        {set_info, _Info} ->
            io:format("erlflow_net:network -> set_deffile ~p ~n", [_Info]),
            NewInfo = lists:flatten([Info, _Info]),
            network(NewInfo, Places, Transitions);
        _else ->
            io:format("erlflow_net:network -> network Received:~p~n", [_else]),
            network(Info, Places, Transitions)
    end.

netsuper(Networks) ->
    receive
        {add_net, ID, Name} ->
            io:format("erlflow_net:netsuper -> add_network ~p ~n", [ID]),
            NewNetworks = lists:append(Networks, {atom_to_list(ID),Name}),
            register(ID, spawn(erlflow_net, network, [[],[],[]])),
            netsuper(NewNetworks);
        {get_status, From} ->
            From ! Networks,
            io:format("erlflow_net:netsuper -> status of net is: networks =~p ~n", [Networks]),
            netsuper(Networks);
        _else ->
            io:format("erlflow_net:netsuper -> Received:~p~n", [_else]),
            netsuper(Networks)
    end.



