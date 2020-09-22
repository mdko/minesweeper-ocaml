open Lib
(* open Boards *)
open Core

let game = Alcotest.testable Types.pp_game ( = )
let board = Alcotest.testable Types.pp_board ( = )
let cell = Alcotest.testable Types.pp_cell ( = )

(* let test_uncover_with_mine () =
  let game_start = Board.array_to_board Boards.Board1.board1_raw |> Game.from_board in
  let pos = Types.{row = 1; col = 4} in
  Alcotest.(check cell) "cells after a step"
    (Game.uncover game_start pos |> (fun g -> Board.get_cell g.board pos) |> Option.value_exn)
    ({position = pos; state = Types.Uncovered; has_mine = true}) *)

let () =
  let open Alcotest in
  run "MyTests" [
    "moves", [
      (* test_case "uncover_with_mine" `Quick test_uncover_with_mine; *)
    ];
  ]