-module(mod2).

-include("/opt/local/lib/erlang/lib/xmerl-1.1.8/include/xmerl.hrl").

-export([process_pnml/0]).

place() ->
	io:format("place created~n"),
        false.

get_id_attr(Node) ->
	#xmlElement{attributes=Attribs} = Node,
	[ #xmlAttribute{name=id, value=Id}] = Attribs,
	Id. 

get_id_attr_arc(Node) ->
	#xmlElement{attributes=Attribs} = Node,
	[ #xmlAttribute{name=target, value=Target},  #xmlAttribute{name=source, value=Source},  #xmlAttribute{name=id, value=ID}] = Attribs,
	[ID, Target, Source]. 

create_object([Node|Rest]) ->
	case Node#xmlElement.name of
		place ->
			ID = get_id_attr(Node),
			register(list_to_atom(ID), spawn(mod2, place, [])),
			io:format("new place ~s ~n", [ID]);
		transition ->
			ID = get_id_attr(Node),
			io:format("new transition ~s~n", [ID]);
		arc ->
			ID = get_id_attr_arc(Node),
			io:format("new arc ~w~n", [ID]);
		Else_ -> 
		false
	end,
	create_object(Rest);

create_object([]) ->
	done.

process_pnml() ->
	{Xml, _} = xmerl_scan:file("example.pnml"),
    	create_object(xmerl_xpath:string("/pnml/net/child::*", Xml)).
