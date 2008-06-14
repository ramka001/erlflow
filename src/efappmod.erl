-module(efappmod).
-author('klacke@bluetail.com').

-include("/opt/local/lib/yaws/include/yaws_api.hrl").
-compile(export_all).

out(A) ->	
    {content, "text/plain",  prepare_response({A#arg.appmoddata, A#arg.querydata})}.


prepare_response({Path, QueryStr}) ->
    PathParts = string:tokens(Path,"/"),
    First = lists:flatten(lists:sublist(PathParts,1,1)),
    case First of
      "nets" ->
        netsuper ! {get_status, self()},
        receive Networks -> Net = Networks end,
        NetworksList = [{networks, prepare_json([Net])}],
        ktuo_json:encode(NetworksList);
      "net" ->
        PartsCount = length(PathParts) - 1,
        io:format("PartsCount:~w~n", [PartsCount]),
        case PartsCount of
          0 ->
            "invalid request";
          1 ->
            Network =  list_to_atom(lists:flatten(lists:sublist(PathParts,2,1))),
            NetworkPid = whereis(Network),
            if 
              is_pid(NetworkPid) ->
                io:format("~w~n",[NetworkPid]),
                NetworkPid !  {get_status, self()},
                receive Response -> [Info, Places, Transitions] = Response end,
                NetworkList = [{info, prepare_json2(Info)}, {places, prepare_json(Places)},{transitions,prepare_json(Transitions)}],
                ktuo_json:encode(NetworkList);
              true -> io_lib:format("invalid request: network doesn't exists. ID=~p~n",[Network])
            end;
          _Other -> "invalid request"
        end;
      _Other -> "invalid request"
    end.
             
prepare_json({Key, Value}) ->
  [{id, {string, Key}},{name,{string, Value}}];
prepare_json([Head | Tail]) ->
  lists:merge([prepare_json(Head)],prepare_json(Tail));
prepare_json([]) -> [].

prepare_json2({Key, Value}) ->
  {Key, {string, Value}};
prepare_json2([Head | Tail]) ->
  	lists:merge([prepare_json2(Head)],prepare_json2(Tail));
prepare_json2([]) -> [].

