-module(csv).

-export([read/1,
         read_file/1
        ]).


-type csv_data() :: list(list(term())).

%-------------------------------------------------------------------------------
-spec read_file(list() | binary()) -> csv_data().
read_file(Path) ->
    case file:read_file(Path) of
        {ok, Data} ->
            read(Data);

        {error, Error} ->
            {error, Error}
    end.


%-------------------------------------------------------------------------------
-spec read(binary()) -> csv_data().
read(Data) ->
    read_line(Data, <<>>, [], []).


%-------------------------------------------------------------------------------
-spec read_line(binary(), binary(), list(binary()), csv_data()) -> csv_data().
read_line(<<>>, _SoFar, _VAcc, LAcc) ->
    {ok, lists:reverse(LAcc)};

read_line(<<$\n, Rest/binary>>, _SoFar, VAcc, LAcc) ->
    read_line(Rest, <<>>, [], [lists:reverse(VAcc) | LAcc]);

read_line(<<$\r, $\n, Rest/binary>>, _SoFar, VAcc, LAcc) ->
    read_line(Rest, <<>>, [], [lists:reverse(VAcc) | LAcc]);

read_line(<<$", Rest/binary>>, _SoFar, VAcc, LAcc) ->
    read_value(Rest, <<>>, VAcc, LAcc);

read_line(<<$,, Rest/binary>>, SoFar, VAcc, LAcc) ->
    read_line(Rest, SoFar, VAcc, LAcc);

read_line(Buff, SoFar, VAcc, LAcc) ->
    read_value(Buff, SoFar, VAcc, LAcc).


%-------------------------------------------------------------------------------
-spec read_value(binary(), binary(), list(binary()), csv_data()) -> csv_data().
read_value(<<$", Rest/binary>>, SoFar, VAcc, LAcc) ->
    read_line(Rest, <<>>, [SoFar | VAcc], LAcc);

read_value(<<C, Rest/binary>>, SoFar, VAcc, LAcc) ->
    read_value(Rest, <<SoFar/binary, C>>, VAcc, LAcc).


