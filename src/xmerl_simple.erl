-module(xmerl_simple).
-export([file/1, stream/1]).

file(F) ->
    xmerl_sax_parser:file(F, options()).

stream(S) ->
    xmerl_sax_parser:stream(S, options()).

options() ->
    [{event_state, []},
     {event_fun, fun event/3}].

event({startElement, _, _LocalName, QName, Attrs}, _, Acc) ->
    Attrs1 = [{qname({Pfx,N}), list_to_binary(V)} || {_, Pfx, N, V} <- Attrs],
    [{qname(QName), Attrs1, []}|Acc];
event({endElement, _, _LocalName, QName}, _, S) ->
    Name = qname(QName),
    case S of
	{Cs, [{Name, As, C}|Acc]} ->
	    end_element(Name, As, iolist_to_binary([C,Cs]), Acc);
	[{Name, Attrs, C}|Acc] ->
	    end_element(Name, Attrs, lists:reverse(C), Acc)
    end;
event({ignorableWhitespace, _}, _, {C, Acc}) ->
    {[C, " "], Acc};
event({characters, Cs}, _, {C, Acc}) ->
    {[C,Cs], Acc};
event({characters, Cs}, _, Acc) ->
    {Cs, Acc};
event(_, _, S) ->
    S.

end_element(Name, As, C, []) ->
    {Name, As, C};
end_element(Name, As, C, [{PName, PAs, PC}|Acc]) ->
    [{PName, PAs, [{Name, As, C}|PC]}|Acc].

qname({NS,Name}) ->
    {list_to_atom(NS),list_to_atom(Name)}.
