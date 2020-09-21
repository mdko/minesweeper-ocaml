open Lib

(* TODO 
   - [x] add number of mines remaining in display
   - [x] add timer
   - [x] add gui
   - change face when its pressed and not released
*)

let () =
    Game.new_game 9 9 10 |> Lib.Gui.game_loop
    (* let board = Board.array_to_board ~nrows:9 ~ncols:9 Boards.Board1.board1_raw in
    Lib.Tty.game_loop Types.{board; total_mines=10; start_time=None} *)

(*
1) Don't place mine on first square revealed
2) Each square has 3 states: uncovered, covered, and flagged
3) Right click to flag; a flagged square deducts one mine from user-visible count
4) Left-clicking uncovers a square
5) Double left-click uncovers ADJACENT unflagged squares
6) If an uncovered square has 0 mines adjacent, all adjacent squares are revealed
*)

(*
Goals:
#1 Write a solver
#2 Write a grid creator
  (maybe use Constraint-Logic Programming in
  conjunction with #1 to only generate solvable ones)
[x] #3 Create a gui
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