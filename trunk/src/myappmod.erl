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
    {content, "text/plain",  ktuo_json:encode(prepare_json([Net]))}.
             
prepare_json({Key, Value}) ->
    [{id, {string, Key}},{name,{string, Value}}];
prepare_json([Head | Tail]) ->
    [{networks, lists:merge([prepare_json(Head)],prepare_json(Tail))}];
prepare_json([]) -> [].
