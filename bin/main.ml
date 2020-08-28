open Lib

(* TODO 
   - add number of mines remaining in display
   - add timer
   - add gui
*)

let rec game_loop game =
  match Game.check_state game with
  | `won -> print_endline "You won!"; Board.board_to_string_numbered game.board |> print_endline
  | `lost -> print_endline "You lost :("; Board.board_to_string_numbered game.board |> print_endline
  | `normal ->
    Board.board_to_string game.board |> print_endline;
    print_endline "Enter a row, col, and action (f=flag,u=uncover,n=uncover neighbors), e.g. \"3 4 f\":";
    let res = try
      Some (Scanf.scanf "%d %d %c\n" (fun r c a -> (r, c, a)))
    with Scanf.Scan_failure _ -> None
    in match res with
    | None -> failwith "Invalid input! TODO fix so we can keep going without an infinite loop"
    | Some (row, col, action) -> 
      print_newline ();
      let pos = Types.{row; col} in
      if Board.is_bad_pos game.board pos then
        begin
          print_endline "Invalid position. Row and column must be inbound (0-indexed).";
          game_loop game
        end
      else
        match action with
        | 'f' -> Game.flag game pos |> game_loop
        | 'u' -> Game.uncover game pos |> Game.tidy |> game_loop
        | 'n' -> Game.uncover_neighbors game pos |> Game.tidy |> game_loop
        | _ -> begin
          print_endline "Invalid action. Must be 'f' (for flag), 'u' (for uncover), or 'n' (for uncover neighbors).";
          game_loop game
        end
    

let () =
    let board = Board.array_to_board 9 9 Test.Board1.board1_raw in
    (* let board = Board.new_board_random 9 9 10 in  *)
    game_loop Types.{board; total_mines=10; time_elapsed=0}

(*
1) Don't place mine on first square revealed
2) Each square has 3 states: uncovered, covered, and flagged
3) Right click to flag; a flagged square deducts one mine from user-visible count
4) Left-clicking uncovers a square
5) (For added UX: Left+right clicks uncovers ADJACENT unflagged squares?)
6) If an uncovered square has 0 mines adjacent, all adjacent squares are revealed
*)

(*
Goals:
#1 Write a solver
#2 Write a grid creator
  (maybe use Constraint-Logic Programming in
  conjunction with #1 to only generate solvable ones)
#3 Create a gui
*)

(*
Beginner:
* 10 mines
* Board size is 8x8, 9x9, or 10x10
Intermediate:
* 40 mines
* Board size is 13x15 or 16x16
Expert:
* 99 mines
* Board size 16x30 or 30x16
*)