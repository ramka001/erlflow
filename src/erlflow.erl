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
    %spawn(erlflow_net, netsuper,[[]]),
    erlflow_xpdl_parser:process("example.xpdl"),
    done.

%%
%% Local Functions
%%

