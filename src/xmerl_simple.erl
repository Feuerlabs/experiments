-module(xmerl_simple).
-export([file/1]).

file(F) ->
    xmerl_sax_parser:file(F, [{event_state, []},
			      {event_fun, fun event/3}]).

event({startElement, _, LocalName, _QName, Attrs}, _, Acc) ->
    Attrs1 = [{list_to_binary(N), list_to_binary(V)} || {_, _, N, V} <- Attrs],
    [{list_to_binary(LocalName), Attrs1, []}|Acc];
event({endElement, _, LocalName, _QName}, _, S) ->
    NBin = list_to_binary(LocalName),
    case S of
	{Cs, [{NBin, As, C}|Acc]} ->
	    end_element(NBin, As, iolist_to_binary([C,Cs]), Acc);
	[{NBin, Attrs, C}|Acc] ->
	    end_element(NBin, Attrs, lists:reverse(C), Acc)
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
