-module(whats_ip).
-export([start/0, start/1]).
-author("Dennis McGrogan <char68.net>").
-original_source("https://stackoverflow.com/a/2219330").

%% Starts whats_ip service on port 80
start() ->
    start(80).

%% Starts whats_ip service on custom port
start(Port) ->
    spawn(fun () -> {ok, Socket} = gen_tcp:listen(Port, [{active, false}]), 
                    loop(Socket) end).

loop(Socket) ->
    {ok, Connection} = gen_tcp:accept(Socket),
    Handler = spawn(fun () -> handle(Connection) end),
    gen_tcp:controlling_process(Connection, Handler),
    loop(Socket).

handle(Connection) ->
    {ok, {IP, _}} = inet:peername(Connection),
    gen_tcp:send(Connection, response(inet:ntoa(IP))),
    gen_tcp:close(Connection).

response(Reply) ->
    B = iolist_to_binary(Reply),
    iolist_to_binary(
      io_lib:fwrite(
         "HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: ~p\n\n~s",
         [size(B), B])).
    