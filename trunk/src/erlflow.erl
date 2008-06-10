%% Authou: josemanuelp
%% Created: 17/05/2008
%% Description: TODO: Add description to erlflow
-module(erlflow).

-export([start/0]).

%%
%% API Functions
%%

start() -> 
    register(netsuper, spawn(erlflow_net, netsuper,[[]])),
    erlflow_xpdl_parser:start(),
    {ok, Files} = file:list_dir("../public/pdefs"),
    load_nets(Files),
    done.

load_nets([Head|Tail]) ->
    io:format("~p~n", [Head]),
    erlflow_xpdl_parser:process("../public/pdefs/" ++ Head),
    load_nets(Tail);
load_nets([]) -> [].

%%
%% Local Functions
%%

