(* Could probably benefit from some ppx deriving equality, etc. *)
type position = {
  row: int;
  col: int;
} [@@deriving eq, show]

type state =
  | Uncovered (* Implicit is that an Uncovered cell doesn't have a mine (otherwise game would be over) *)
  | Covered
  | Flagged
[@@deriving eq, show]

type cell = {
  position: position;
  state: state;
  has_mine: bool;
}
[@@deriving eq, show]

type board = {
  nrows: int;
  ncols: int;
  cells: cell list;
} 
[@@deriving eq, show]

type game = {
    board: board;
    total_mines: int;
    start_time: int option;
}
[@@deriving eq, show]