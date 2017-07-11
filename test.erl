-module(test).

-export([connect/0]).

% -record(myrec, {field1, field2}).

connect() -> 
	{ok, Fd} = file:open("Newfile.txt", [write]), 
	file:write(Fd,"New Line").
	% {ok, Client} = cqerl:get_client({}),
	% Client.