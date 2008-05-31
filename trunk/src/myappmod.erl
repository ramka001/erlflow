-module(myappmod).
-author('klacke@bluetail.com').

-include("/opt/local/lib/yaws/include/yaws_api.hrl").
-compile(export_all).

box(Str) ->
    {'div',[{class,"box"}],
     {pre,[],Str}}.

out(A) ->	
    netsuper ! {get_status, self()},
    receive Networks -> Net = Networks end,
    %JsonMap = lists:map(fun(X) -> if is_atom(X) -> atom_to_list(X); true -> X end end, Net),
    JsonVar = prepare_json([Net]),
    %JVar =  rfc4627:encode([sksksi,"sksks"]),
    JVar = ktuo_json:encode([{string, "wwwdddd"},{string, "ksksks"}]),
    %JVar = json:encode(JsonVar),
    {ehtml,
     [{p,[],
       box(io_lib:format("A#arg.appmoddata1 = ~p~n"
                         "A#arg.appmod_prepath = ~p~n"
                         "A#arg.querydata = ~p~n" 
                         "Json = ~p~n", 
                         [A#arg.appmoddata,
                          A#arg.appmod_prepath,
                          A#arg.querydata,
			  JsonVar
			 ]))}]}.

prepare_json2({Key , Value}) ->
	{Key, {string, Value}}.
prepare_json([Head | Tail]) ->
	prepare_json2(Head),
	prepare_json(Tail).
