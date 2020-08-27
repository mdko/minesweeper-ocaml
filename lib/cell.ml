type position = {
  row: int;
  col: int;
}

type state =
  | Uncovered
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