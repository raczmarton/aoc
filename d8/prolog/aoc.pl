#!/usr/bin/env -S swipl -O

:- use_module(library(dcg/basics)).
:- use_module(library(dcg/high_order)).
:- use_module(library(pio)).

:- dynamic antenna/2.

field(empty) --> `.`, !.
field(X) --> nonblank(X).

row(Row) -->
    sequence(field, Row).

map(Map) -->
    sequence(row, (blank, \+ eos), Map), blank.

get_antennas([], _).
get_antennas([Row | Rows], Y) :-
    get_antennas(Row, Y, 0),
    Y1 is Y + 1,
    get_antennas(Rows, Y1).

get_antennas([], _, _).
get_antennas([Tile | Tiles], Y, X) :-
    ( Tile \= empty -> assertz(antenna(Tile, X-Y)) ; true ),
    X1 is X + 1,
    get_antennas(Tiles, Y, X1).

    go(Part, Dim, X) :-
        setof(Pos, antinode(Part, Dim, Pos), Ps),
        length(Ps, X).
    
    antinode(Part, Dim, X-Y) :-
        antenna(A, X1-Y1),
        antenna(A, X2-Y2),
        X1-Y1 \= X2-Y2,
        find_antinodes(Part, Dim, X1, Y1, X2, Y2, X, Y),
        X >= 0, Y >= 0, X < Dim, Y < Dim.
    
    find_antinodes(part1, _, X1, Y1, X2, Y2, X, Y) :-
        (
            X is 2 * X1 - X2,
            Y is 2 * Y1 - Y2
        ;   X is 2 * X2 - X1,
            Y is 2 * Y2 - Y1
        ).
    
    find_antinodes(part2, Dim, X1, Y1, X2, Y2, X, Y) :-
        DNeg is -Dim,
        between(DNeg, Dim, N),
        X is X1 + N * (X1 - X2),
        Y is Y1 + N * (Y1 - Y2).

:- initialization(main, main).

main(_) :-
    open('input', read, Str),
    retractall(antenna(_, _)),
    phrase_from_stream(map(Map), Str),
    get_antennas(Map, 0),
    length(Map, Dim), !,
    go(part1, Dim, Out1),
    format('Part 1: ~a~n', Out1),
    go(part2, Dim, Out2),
    format('Part 2: ~a~n', Out2).

