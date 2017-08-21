%%%-------------------------------------------------------------------
%%% @author Tsesar Rizqi <tsesarrizqi@gmail.com>
%%% @doc
%%%
%%% @end
%%%-------------------------------------------------------------------
-module(mod_mam_modified_cassandra).

-behaviour(mod_mam_modified).

%% API
-export([init/2, remove_user/2, remove_room/3, delete_old_messages/3,
     extended_fields/0, store/7, write_prefs/4, get_prefs/2, select/8]).

-include("jlib.hrl").
-include("mod_mam.hrl").
-include("logger.hrl").
-include("cqerl.hrl").

-define(CONSISTENCY, quorum).

%%%===================================================================
%%% API
%%%===================================================================
init(Host, _Opts) ->
    TabName = binary_to_atom(list_to_binary([<<"mycqerl">>,Host]),utf8),
    ets:new(TabName, [named_table, protected, set, {keypos, 1}]),
    case connection:create_cqerl_connection(TabName) of
      {ok,Client} ->
        Pid = connection:start_connection_maintainer(Client,TabName),
        ets:insert(TabName, {connection_maintainer, Pid}),
        ets:give_away(TabName,Pid,[]),
        ok;
      Err ->
        ?INFO_MSG("Error in initiating mod_mam_modified_cassandra: ~p", [Err]),
        Err
    end.

remove_user(LUser, _LServer) ->
    Client = get_client(),
    Query = make_remove_user_query(LUser),
    {ok,RawCountRes} = cqerl:run_query(Client,list_to_binary([<<"select count(*) from archive_prefs where username ='">>,LUser,<<"'">>])),
    [{count,Count}] = cqerl:head(RawCountRes),
    case cqerl:run_query(Client, Query) of
        {ok, _} ->
            {updated,Count};
        Err ->
            ?INFO_MSG("CQErl error when running query: ~p", [Err]),
            Err
    end.

remove_room(LServer, LName, LHost) ->
    LUser = jid:to_string({LName, LHost, <<>>}),
    remove_user(LUser, LServer).

delete_old_messages(_ServerHost, TimeStamp, Type) ->
    Client = get_client(),
    case Type of 
        all ->
            Query = make_delete_old_messages_query(TimeStamp),
            case cqerl:run_query(Client, Query) of
                {ok, _} ->
                    ok;
                Err ->
                    ?INFO_MSG("CQErl error when running query: ~p", [Err]),
                    Err
            end;
        chat ->
            Queries = make_delete_old_messages_with_type_query(<<"chat">>,TimeStamp),
            [cqerl:run_query(Client,Q) || Q <- Queries],
            ok;
        groupchat ->
            Queries = make_delete_old_messages_with_type_query(<<"groupchat">>,TimeStamp),
            [cqerl:run_query(Client,Q) || Q <- Queries],
            ok;
        _ -> 
            ?INFO_MSG("Error in deleting messages. Unsupported type: ~p", [Type]),
            unsupported_type
    end.

extended_fields() ->
    [#xmlel{name = <<"field">>,
        attrs = [{<<"type">>, <<"text-single">>},
             {<<"var">>, <<"withtext">>}]}].

%%% Note that UPDATE in CQL is synonymous with UPSERT in SQL
write_prefs(LUser, _LServer, #archive_prefs{default = Default, never = Never, always = Always}, _ServerHost) ->
    Client = get_client(),
    Query = make_write_prefs_query(LUser,Default,Always,Never),
    case cqerl:run_query(Client, Query) of
        {ok, _} ->
            ok;
        Err ->
            ?INFO_MSG("CQErl error when running query: ~p", [Err]),
            Err
    end.

get_prefs(LUser, LServer) ->
    Client = get_client(),
    Query = make_get_prefs_query(LUser),
    case cqerl:run_query(Client, Query) of
        {ok, Result} ->
            [{def,SDefault},{always,SAlways},{never,SNever}] = cqerl:head(Result),
            Default = erlang:binary_to_existing_atom(SDefault, utf8),
            Always = decode_term(SAlways),
            Never = decode_term(SNever),
            {ok, #archive_prefs{us = {LUser, LServer},
                default = Default,
                always = Always,
                never = Never}};
        Err ->
            ?INFO_MSG("CQErl error when running query: ~p", [Err]),
            Err
    end.

store(Pkt, _LServer, {LUser, LHost}, Type, Peer, Nick, _Dir) ->
    TSinteger = p1_time_compat:system_time(micro_seconds),
    ID = jlib:integer_to_binary(TSinteger),
    Client = get_client(),
    Query = make_store_query(Pkt, LUser, LHost, Type, Peer, Nick, ID),
    case cqerl:run_query(Client, Query) of
        {ok, _} ->
            {ok, ID};
        Err ->
            ?INFO_MSG("CQErl error when running query: ~p", [Err]),
            Err
    end.

select(LServer, JidRequestor, #jid{luser = LUser} = JidArchive, Start, End, With, RSM, MsgType) ->
    Client = get_client(),

    User = case MsgType of
           chat -> 
                LUser;
           {groupchat, _Role, _MUCState} -> 
                jid:to_string(JidArchive)
       end,
    
    {MainQuery, CountQuery} = make_select_query(User, LServer, Start, End, With, RSM), 
    {ok,RawMainRes} = cqerl:run_query(Client, MainQuery),
    {ok,RawCountRes} = cqerl:run_query(Client, CountQuery),
    MainRes = fetch_all_rows(RawMainRes),
    CountRes = fetch_all_rows(RawCountRes),

    case {MainRes,CountRes} of
        {Res0, Count0} ->
            {Max, Direction} = case RSM of
                       #rsm_in{max = M, direction = D} -> 
                            {M, D};
                       _ -> 
                            {undefined, undefined}
                       end,
            
            Res1 = case Direction of
                before -> 
                      lists:reverse([[integer_to_binary(T)|[A || {_,A} <- Rest]] || [{_,T}|Rest] <- Res0]);
                _ -> 
                      [[integer_to_binary(T)|[A || {_,A} <- Rest]] || [{_,T}|Rest] <- Res0]
            end,
            
            Count = integer_to_binary(length(Count0)),
            {Res, IsComplete} =
                if Max >= 0 andalso Max /= undefined andalso length(Res1) > Max ->
                    if Direction == before ->
                        {lists:nthtail(1, Res1), false};
                       true ->
                        {lists:sublist(Res1, Max), false}
                    end;
                   true ->
                    {Res1, true}
                end,
            
            {lists:flatmap(
              fun([TS, XML, PeerBin, Kind, Nick]) ->
                  try
                      #xmlel{} = El = fxml_stream:parse_element(XML),
                      Now = usec_to_now(jlib:binary_to_integer(TS)),
                      PeerJid = jid:tolower(jid:from_string(PeerBin)),
                      T = case Kind of
                            <<"">> -> 
                                chat;
                            null -> 
                                chat;
                            _ -> 
                                jlib:binary_to_atom(Kind)
                          end,                      
                      [{TS, jlib:binary_to_integer(TS),
                        mod_mam_modified:msg_to_el(
                          #archive_msg{timestamp = Now,
                                       packet = El,
                                       type = T,
                                       nick = Nick,
                                       peer = PeerJid},
                          MsgType, JidRequestor, JidArchive)}]
                  catch 
                      _:Err ->
                          ?ERROR_MSG("failed to parse data from CQL: ~p. "
                            "The data was: "
                            "timestamp = ~s, xml = ~s, "
                            "peer = ~s, kind = ~s, nick = ~s",
                            [Err, TS, XML, PeerBin, Kind, Nick]),
                          []
                  end
              end, Res), IsComplete, jlib:binary_to_integer(Count)};
        _ ->
            {[], false, 0}
    end.

%%%===================================================================
%%% Internal functions
%%%===================================================================
get_client() ->
  AtomTables = lists:filter(fun(A) -> is_atom(A) end, ets:all()),
  TableString = lists:map(fun(A) -> atom_to_list(A) end, AtomTables),
  MycqerlTable = hd(lists:filter(fun(A) -> string:str(A,"mycqerl") > 0 end, TableString)),
  [{_, Client}] = ets:lookup(list_to_atom(MycqerlTable), client),
  Client.

fetch_all_rows(Res0) ->
  lists:append([cqerl:all_rows(Res0),
    case cqerl:has_more_pages(Res0) of
            true -> 
              {ok, Res1} = cqerl:fetch_more(Res0),
              fetch_all_rows(Res1);
            false -> 
              []
        end
  ]).

get_all_users() ->
    Client = get_client(),
    case cqerl:run_query(Client,"select distinct username from archive;") of
      {ok,Res} ->
        [User || [{username,User}|[]] <- fetch_all_rows(Res)];
      _ -> 
        []
    end.

get_from_mv(Type) ->
    Client = get_client(),
    case cqerl:run_query(Client,list_to_binary([<<"select username,timestamp from archive_by_kind where kind='">>,Type,<<"';">>])) of
      {ok,Res} ->
        fetch_all_rows(Res);
      _ -> 
        []
    end.

standard_escape(S) ->
    << <<(case Char of
              $' -> << "''" >>;
              _ -> << Char >>
          end)/binary>> || <<Char>> <= S >>.

decode_term(Bin) ->
    Str = binary_to_list(<<Bin/binary, ".">>),
    {ok, Tokens, _} = erl_scan:string(Str),
    {ok, Term} = erl_parse:parse_term(Tokens),
    Term.

now_to_usec({MSec, Sec, USec}) ->
    (MSec*1000000 + Sec)*1000000 + USec.

usec_to_now(Int) ->
    Secs = Int div 1000000,
    USec = Int rem 1000000,
    MSec = Secs div 1000000,
    Sec = Secs rem 1000000,
    {MSec, Sec, USec}.
    
make_remove_user_query(User) ->
    DeleteStatement = fun(Archive) ->
          list_to_binary([<<"delete from ">>,Archive,<<" where username='">>,User,<<"';">>]) 
        end,
    #cql_query_batch{
      consistency = ?CONSISTENCY,
      mode=logged,
      queries=[
        #cql_query{consistency = ?CONSISTENCY, statement = DeleteStatement(<<"archive">>)},
        #cql_query{consistency = ?CONSISTENCY, statement = DeleteStatement(<<"archive_prefs">>)}
      ]
    }.

make_delete_old_messages_query(TimeStamp) ->
    Users = get_all_users(),
    TS = integer_to_binary(now_to_usec(TimeStamp)),
            
    #cql_query{consistency = ?CONSISTENCY, statement = 
            list_to_binary([<<"delete from archive where username in (">>,
              [[<<"'">>,U,<<"',">>] || U <- Users],
              <<"'user') and timestamp<">>,TS,<<";">>])}.

make_delete_old_messages_with_type_query(Type, TimeStamp) ->
    UserTS = get_from_mv(Type),
    TS = integer_to_binary(now_to_usec(TimeStamp)),
    
    [#cql_query{
      consistency = ?CONSISTENCY, 
      statement = list_to_binary([<<"delete from archive where username = '">>,
        User,<<"' and timestamp = ">>,integer_to_binary(TS1)])} 
    || [{username,User},{timestamp,TS1}] <- UserTS, TS1 < TS].

make_write_prefs_query(User,Default,Always,Never) ->
    #cql_query{
      consistency = ?CONSISTENCY,
      statement = "UPDATE archive_prefs SET def = ?, always = ?, never = ?, created_at = toTimestamp(now()) where username = ?;",
      values = [
          {def, lists:flatten(io_lib:format("~p",[Default]))},
          {always, lists:flatten(io_lib:format("~p",[Always]))},
          {never, lists:flatten(io_lib:format("~p",[Never]))},
          {username, binary_to_list(User)}
          ]}.

make_get_prefs_query(User) ->
    #cql_query{
      consistency = ?CONSISTENCY,
      statement = "SELECT def, always, never FROM archive_prefs where username=?;",
      values = [{username, binary_to_list(User)}]}.

make_store_query(Pkt, LUser, LHost, Type, Peer, Nick, ID) ->
    SUser = case Type of
            chat -> 
                LUser;
            groupchat -> 
                jid:to_string({LUser, LHost, <<>>})
        end,
    BarePeer = jid:to_string(jid:tolower(jid:remove_resource(Peer))),
    LPeer = jid:to_string(jid:tolower(Peer)),
    XML = fxml:element_to_binary(Pkt),
    Body = fxml:get_subtag_cdata(Pkt, <<"body">>),
    SType = jlib:atom_to_binary(Type),  
    
    InsertQuery = list_to_binary(
        [<<"INSERT INTO archive (username,timestamp,peer,bare_peer,xml,txt,kind,nick,created_at) values(">>,
        <<"'">>,standard_escape(SUser),<<"',">>,
        ID,<<",">>,
        <<"'">>,standard_escape(LPeer),<<"',">>,
        <<"'">>,standard_escape(BarePeer),<<"',">>,
        <<"'">>,standard_escape(XML),<<"',">>,
        <<"'">>,standard_escape(Body),<<"',">>,
        <<"'">>,standard_escape(SType),<<"',">>,
        <<"'">>,standard_escape(Nick),<<"',">>,
        <<"toTimestamp(now()));">>]),
    #cql_query{consistency = ?CONSISTENCY, statement = InsertQuery}.

make_select_query(User, _LServer, Start, End, With, RSM) ->
    {Max, Direction, ID} = case RSM of
            #rsm_in{} ->
                {RSM#rsm_in.max,
                RSM#rsm_in.direction,
                RSM#rsm_in.id};
            none ->
                {none, none, <<>>}
        end,

    LimitClause = 
            if is_integer(Max), Max >= 0 ->
                [<<" limit ">>, jlib:integer_to_binary(Max+1)];
            true ->
                []
        end,

    WithClause = case With of
            {text, _} ->
                [];
            {_, _, <<>>} ->
                [<<" and bare_peer='">>, standard_escape(jid:to_string(With)), <<"'">>];
            {_, _, _} ->
                [<<" and peer='">>, standard_escape(jid:to_string(With)), <<"'">>];
            none ->
                []
        end,

    PageClause = case catch jlib:binary_to_integer(ID) of
             I when is_integer(I), I >= 0 ->
                case Direction of
                    before ->
                       {before,ID};
                    aft ->
                       {aft,ID};
                    _ ->
                       []
                end;
             _ ->
                []
         end,
    
    StartClause = case Start of
          {_, _, _} ->
              [<<" and timestamp >= ">>,jlib:integer_to_binary(now_to_usec(Start))];
          _ ->
              []
      end,

    EndClause = case End of
        {_, _, _} ->
            [<<" and timestamp <= ">>,jlib:integer_to_binary(now_to_usec(End))];
        _ ->
            []
    end,

    BottomIntervalClause = case {Start,PageClause} of
            {{_, _, _},{aft,ID}} ->
                  case jlib:binary_to_integer(ID) >= now_to_usec(Start) of                        
                       true -> 
                          [<<" and timestamp > ">>, ID];
                       false -> 
                          StartClause
                  end;
            {_,{aft,ID}} ->
                  [<<" and timestamp > ">>, ID];
            {{_, _, _},_} -> 
                  StartClause;
            _ ->
            []
        end,

    TopIntervalClause = case {End,PageClause} of
            {{_, _, _},{before,ID}} ->
                case jlib:binary_to_integer(ID) =< now_to_usec(End) of 
                     true -> 
                        [<<" and timestamp < ">>, ID];
                     false -> 
                        EndClause
                end;
            {_,{before,ID}} ->
                [<<" and timestamp < ">>, ID];
            {{_, _, _},_} -> 
                EndClause;
            _ ->
                []
        end,

    SUser = standard_escape(User),

    MainStatement = fun(Order) -> list_to_binary([<<"SELECT timestamp, xml, peer, kind, nick FROM archive WHERE username='">>,
                  SUser, <<"'">>, WithClause, BottomIntervalClause, TopIntervalClause, Order, LimitClause, <<" ALLOW FILTERING;">>]) 
              end,

    CountStatement = list_to_binary([<<"SELECT username FROM archive WHERE username='">>,
                  SUser, <<"'">>, WithClause, StartClause, EndClause, <<" ALLOW FILTERING;">>]),

    case Direction of
            before ->
                {#cql_query{consistency = ?CONSISTENCY, statement = MainStatement(<<" ORDER BY TIMESTAMP DESC">>)},
                #cql_query{consistency = ?CONSISTENCY, statement = CountStatement}};
            _ ->
                {#cql_query{consistency = ?CONSISTENCY, statement = MainStatement(<<>>)},
                #cql_query{consistency = ?CONSISTENCY, statement = CountStatement}}
        end.
