%%==============================================================================
%% The Language Server Protocol
%%==============================================================================
-module(els_protocol).

%%==============================================================================
%% Exports
%%==============================================================================
%% Messaging API
-export([ notification/2
        , request/2
        , request/3
        , response/2
        , error/2
        ]).

%% Data Structures
-export([ range/1
        , range_line/1
        ]).

%%==============================================================================
%% Includes
%%==============================================================================
-include("els_core.hrl").
-include_lib("kernel/include/logger.hrl").

%%==============================================================================
%% Messaging API
%%==============================================================================
-spec notification(binary(), any()) -> binary().
notification(Method, Params) ->
  Message = #{ jsonrpc => ?JSONRPC_VSN
             , method  => Method
             , params  => Params
             },
  content(jsx:encode(Message)).

-spec request(number(), binary()) -> binary().
request(RequestId, Method) ->
  Message = #{ jsonrpc => ?JSONRPC_VSN
             , method  => Method
             , id      => RequestId
             },
  content(jsx:encode(Message)).

-spec request(number(), binary(), any()) -> binary().
request(RequestId, Method, Params) ->
  Message = #{ jsonrpc => ?JSONRPC_VSN
             , method  => Method
             , id      => RequestId
             , params  => Params
             },
  content(jsx:encode(Message)).

-spec response(number(), any()) -> binary().
response(RequestId, Result) ->
  Message = #{ jsonrpc => ?JSONRPC_VSN
             , id      => RequestId
             , result  => Result
             },
  ?LOG_DEBUG("[Response] [message=~p]", [Message]),
  content(jsx:encode(Message)).

-spec error(number(), any()) -> binary().
error(RequestId, Error) ->
  Message = #{ jsonrpc => ?JSONRPC_VSN
             , id      => RequestId
             , error   => Error
             },
  ?LOG_DEBUG("[Response] [message=~p]", [Message]),
  content(jsx:encode(Message)).

%%==============================================================================
%% Data Structures
%%==============================================================================
-spec range(poi_range()) -> range().
range(#{ from := {FromL, FromC}, to := {ToL, ToC} }) ->
  #{ start => #{line => FromL - 1, character => FromC - 1}
   , 'end' => #{line => ToL - 1,   character => ToC - 1}
   }.

-spec range_line(poi_range()) -> range().
range_line(#{ from := {FromL, _}, to := {ToL, _} }) ->
  #{ start => #{line => FromL - 1, character => 0}
   , 'end' => #{line => ToL,   character => 1}
   }.

%%==============================================================================
%% Internal Functions
%%==============================================================================
-spec content(binary()) -> binary().
content(Body) ->
  els_utils:to_binary([headers(Body), "\r\n", Body]).

-spec headers(binary()) -> iolist().
headers(Body) ->
  io_lib:format("Content-Length: ~p\r\n", [byte_size(Body)]).
