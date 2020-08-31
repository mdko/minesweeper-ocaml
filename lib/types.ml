(* Could probably benefit from some ppx deriving equality, etc. *)
type position = {
  row: int;
  col: int;
}

type state =
  | Uncovered (* Implicit is that an Uncovered cell doesn't have a mine (otherwise game would be over) *)
  | Covered
  | Flagged

type cell = {
  position: position;
  state: state;
  has_mine: bool;
}

type board = {
  nrows: int;
  ncols: int;
  cells: cell list;
} 

type game = {
    board: board;
    total_mines: int;
    start_time: int option;
}