-module(erlflow).

-include("/opt/local/lib/erlang/lib/xmerl-1.1.8/include/xmerl.hrl").

-export([start/0,netsuper/3,process_pnml/1,place/5,transition/4]).

place(ID, Name, Inputs, Outputs, Tokens) ->
    receive
        {add_token, Token} ->
            io:format("token received: ~s ~n", [Token]),
            NewTokens = lists:flatten(Tokens, [Token]),
            place(ID, Name, Inputs, Outputs, NewTokens);
        {input, Source} ->
            io:format("~p has a new input arc from ~p ~n", [ID, Source]),
            NewInputs = lists:flatten(Inputs, [Source]),
            place(ID, Name, NewInputs, Outputs, Tokens);
        {output, Target} ->
            io:format("~p has a new output arc to ~p ~n", [ID, Target]),
            NewOutputs = lists:flatten(Outputs, [Target]),
            place(ID, Name, Inputs, NewOutputs, Tokens);
        {status, From} ->
            io:format("status requested by ~p ~n", [From]),
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
        {input, Source} ->
            io:format("~p has a new input arc from ~p ~n", [ID, Source]),
            NewInputs = lists:flatten(Inputs, [Source]),
            transition(ID, Name, NewInputs, Outputs);
        {output, Target} ->
            io:format("~p has a new output arc to ~p ~n", [ID, Target]),
            NewOutputs = lists:flatten(Outputs, [Target]),
            transition(ID, Name, Inputs, NewOutputs);
        {status, From} ->
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

get_id_attr(Node) ->
    #xmlElement{attributes=Attribs} = Node,
    [ #xmlAttribute{name=id, value=ID}] = Attribs,
    list_to_atom(ID). 

get_id_attr_arc(Node) ->
    #xmlElement{attributes=Attribs} = Node,
    [ #xmlAttribute{name=target, value=Target},  #xmlAttribute{name=source, value=Source},  #xmlAttribute{name=id, value=ID}] = Attribs,
    {list_to_atom(ID), list_to_atom(Target), list_to_atom(Source)}. 

extract_name(R, L) when is_record(R, xmlElement) ->
        lists:foldl(fun extract_name/2, L, R#xmlElement.content);
extract_name(#xmlText{parents=[{text,_},{name,_},{_,_},{net,_},{pnml,_}], value=V}, _) ->
        V;
extract_name(_, L) ->
        L.

create_object([Node|Rest]) ->
    case Node#xmlElement.name of
        place ->
            ID = get_id_attr(Node),
            Name = extract_name(Node, []),
            register(ID, spawn(erlflow, place, [ID,Name,[],[],[]])),
            netsuper ! {addPlace, ID},
            io:format("new place ~s:~p ~n", [ID, Name]),
            create_object(Rest);
        transition ->
            ID = get_id_attr(Node),
            Name = extract_name(Node, []),
            register(ID, spawn(erlflow, transition, [ID,Name,[],[]])),
            netsuper ! {addTransition, ID},
			io:format("new transition ~s:~p ~n", [ID, Name]),
            create_object(Rest);
        arc ->
            ID = get_id_attr_arc(Node),
            {_, Target, Source} = ID,
            Source ! {output, Target},
            Target ! {input, Source},
            io:format("new arc ~w~n", [ID]),
            create_object(Rest);
        _else ->
            create_object(Rest)
    end;
create_object([]) ->
    done.

process_pnml(PnmlFile) ->
    {Xml, _} = xmerl_scan:file(PnmlFile),
    create_object(xmerl_xpath:string("/pnml/net/child::*", Xml)),
    registered().

netsuper(PnmlFile, Places, Transitions) ->
    receive
        {init, _PnmlFile} ->
            process_pnml(_PnmlFile),
            netsuper(_PnmlFile, Places, Transitions);
        {add_place, ID} ->
            NewPlaces = lists:flatten(Places, [ID]),
            io:format("addPlace ~p ~n", [NewPlaces]),
            netsuper(PnmlFile, NewPlaces, Transitions);
        {add_transition,  ID} ->
            NewTransitions = lists:flatten(Transitions, [ID]),
            io:format("addPlace ~p ~n", [NewTransitions]),
            netsuper(PnmlFile, Places, NewTransitions);
        {get_status, From} ->
            From ! [Places, Transitions],
            io:format("status of net is: places=~p transitions=~p ~n", [Places, Transitions]),
            netsuper(PnmlFile, Places, Transitions);
        {status, State} ->
            io:format("status of ~w is: ~w inputs, ~w outputs, ~w tokens.~n", State),
            netsuper(PnmlFile, Places, Transitions);
        _else ->
            netsuper(PnmlFile, Places, Transitions)
    end.

start() -> 
    register(netsuper, spawn(erlflow, netsuper, [[],[],[]])),
    netsuper ! {init, "example.pnml"},
    done.

