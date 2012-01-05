-module(nc_simple).
-compile(export_all).

reply({{'','rpc-reply'}, Attrs, Body}) ->
    Id = attr_value({'','message-id'}, Attrs),
    {rpc_reply, Id, [rpc_reply(E) || E <- Body]}.


rpc_reply({{'','rpc-error'}, _, Body}) ->
    {error, [{type, error_info(type, elem_content({'','error-type'}, Body))},
	     {tag,  error_info(tag, elem_content({'','error-tag'}, Body))},
	     {severity, error_info(severity, elem_content({'','error-severity'}, Body))}]};
rpc_reply(Other) ->
    Other.


error_info(type, <<"application">>) -> application;
error_info(type, <<"protocol">>   ) -> protocol;
error_info(type, <<"rpc">>        ) -> rpc;
error_info(type, <<"transport">>  ) -> transport;
%%
error_info(severity, <<"error">>  ) -> error;
error_info(severity, <<"warning">>) -> warning;
error_info(_, I) -> I.
    

attr_value(K, [{K,V}|_]) ->
    V;
attr_value(K, [_|T]) ->
    attr_value(K, T).

elem_content(Name, [{Name, _, C}|_]) ->
    C;
elem_content(Name, [_|T]) ->
    elem_content(Name, T).

