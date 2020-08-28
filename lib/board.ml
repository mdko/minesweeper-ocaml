open Types

let make_pos nrows i =
  {row=(i / nrows); col=(i mod nrows)}

(* If 100 cells to deal with, 10 mines remaining; each cell has a 1/10 chance of having a mine.
   Generate a number between 0 and  (100/10) * 10. If number is 0, place a mine.
   Now there are 99 cells, 0 and 99/10 = 0 and 9.9 * 10 = between 0 and 99. If number is between 0 and 10,
   place a mine.
   If 50 cells, 10 mines still; each cell has a 1/5 chance.
   50*10/10 = 50, generate number between 0 and 50, choose if between 0 and 10. *)

let new_board_random (nrows: int) (ncols: int) (nmines: int) : board =
  Random.self_init ();
  let ncells = nrows * ncols in
  let rec build i mines_remaining =
    if i = ncells then []
    else
      let position = make_pos nrows i in
      let has_mine =
        if mines_remaining > 0 then
          let max = ((ncells - i) * 10) / mines_remaining in
          let rand = Random.int max in
          rand < 10
        else
          false
      in
      let cell = {position; state=Covered; has_mine} in
      let mines_remaining = if has_mine then mines_remaining - 1 else mines_remaining in
      cell :: build (i + 1) mines_remaining 
  in
  let cells = build 0 nmines in 
  {nrows; ncols; cells}

let new_board_solveable_no_guesses nrows ncols _nmines = {nrows; ncols; cells=[]}

let is_bad_pos {nrows; ncols; _} {row; col} : bool =
  row < 0 || row >= nrows || col < 0 || col >= ncols

let get_cell board pos =
  if is_bad_pos board pos
    then None
    else
      let {cells; ncols; _} = board in
      let {row; col} = pos in
      Some (List.nth cells (row * ncols + col))

let set_cell board cell =
  let cells = List.fold_right (fun curr accum ->
    if curr.position = cell.position 
    then
      cell :: accum
    else
      curr :: accum
    )
  board.cells
  []
  in
  {board with cells}

let rel_pos {row; col} = function
  | `upleft -> {row = row-1; col=col-1}
  | `up -> {row = row-1; col}
  | `upright -> {row = row-1; col=col+1}
  | `left -> {row; col=col-1}
  | `right -> {row; col=col+1}
  | `downleft -> {row = row + 1; col=col-1}
  | `down -> {row = row + 1; col}
  | `downright -> {row = row + 1; col=col+1}

let map_opt (f: 'a -> 'b option) (l: 'a list) : 'b list =
  List.fold_right 
  (fun el accum -> 
    match f el with
    | None -> accum
    | Some el -> el :: accum
  )
  l
  []

let get_neighbors board position : cell list =
  map_opt (fun dir -> rel_pos position dir |> get_cell board) [
    `upleft;
    `up;
    `upright;
    `left;
    `right;
    `downleft;
    `down;
    `downright;
  ] 

let n_mine_neighbors board cell =
  get_neighbors board cell.position |> List.filter (fun (c: cell) -> c.has_mine) |> List.length

let board_to_string ?(f: (cell -> string) option) board =
  let {ncols; cells; _} = board in
  List.map (fun (c: cell) ->
    let s = match f with
      | None -> 
        (match c.state with
        | Uncovered ->
          if c.has_mine
            then "X "
            else Printf.sprintf "%d " (n_mine_neighbors board c)
        | Flagged -> "> "
        | Covered -> "_ "
        )
      | Some f -> f c
    in
    let nl = if c.position.col = ncols - 1 then "\n" else "" in
    s ^ nl
  ) cells
  |> String.concat ""

let board_to_string_numbered board =
  let f = fun (c: cell) -> 
    if c.has_mine
      then "X "
      else Printf.sprintf "%d " (n_mine_neighbors board c)
  in
  board_to_string ~f board

let board_to_string_positions =
  let f = fun (c: cell) -> Printf.sprintf "(%d,%d)" c.position.row c.position.col in
  board_to_string ~f

let array_to_board nrows ncols = function
| [] -> failwith "empty array"
| xs ->
  let cells = List.mapi (fun i n -> 
      {position = make_pos nrows i; state = Covered; has_mine = (n = 1)}) xs in
  {
      nrows;
      ncols;
      cells;
  }