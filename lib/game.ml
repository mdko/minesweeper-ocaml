open Types

let new_game ncols nrows nmines = 
  let board = Board.new_board_random ncols nrows nmines in
  Types.{board; total_mines=nmines; start_time=None}

let flag game pos =
  match Board.get_cell game.board pos with
  | None -> game
  | Some cell -> 
    (* Toggle the flag; None means no need to update board later *)
    let new_cell =
      match cell.state with
        | Uncovered -> None
        | Flagged -> Some {cell with state = Covered}
        | Covered -> Some {cell with state = Flagged}
    in 
    match new_cell with
      | None -> game
      (* Update the board *)
      | Some new_cell -> {game with board=Board.set_cell game.board new_cell}

let uncover game pos =
  match Board.get_cell game.board pos with
  | None -> game
  | Some cell -> 
    (* Can only uncover Covered cells (i.e. no flags, not uncovered already) *)
    match cell.state with
    | Uncovered | Flagged -> game
    | Covered ->
      let new_cell = {cell with state = Uncovered} in
      {game with board=Board.set_cell game.board new_cell}

(* Uncovers the unflagged neighbors of all empty uncovered cells,
   where 'empty' means surrounded by zero mines. *)
let tidy game =
  (* Reach a fixpoint *)
  let empty_uncovered_cells board = List.filter
    (fun cell -> cell.state = Uncovered && (Board.n_mine_neighbors board cell.position) = 0)
    board.cells
  in
  let cells_to_reveal board = List.map
    (fun cell -> Board.get_neighbors board cell.position)
    (empty_uncovered_cells board)
    |> List.concat
    |> List.sort_uniq (fun cell1 cell2 -> if cell1.position = cell2.position then 0 else -1)
  in 
  let same l1 l2 =
    let comp = (fun p1 p2 -> if p1 = p2 then 0 else -1) in
    let l1 = List.map (fun cell -> cell.position) l1 |> List.sort_uniq comp in
    let l2 = List.map (fun cell -> cell.position) l2 |> List.sort_uniq comp in
    l1 = l2
  in
  let rec fixpoint to_reveal game =
    (* Uncover some more empty cells *)
    let game = List.fold_left (fun game cell -> uncover game cell.position) game to_reveal in
    (* See if that causes more to be candidates *)
    let more_to_reveal = cells_to_reveal game.board in
    (* This is hacky, but I'm tired... *)
    if same to_reveal more_to_reveal
    then game
    else fixpoint more_to_reveal game
  in
  fixpoint (cells_to_reveal game.board) game

(* Uncover all non-flagged (i.e. covered) neighbors of a cell; a quick way
   to uncover cells you know should be empty (but if one of
   the neighbors is a mine, you lose) *)
let uncover_neighbors game pos =
  Board.get_neighbors game.board pos |>
  List.filter (fun cell -> cell.state = Covered) |>
  List.fold_left (fun game cell -> uncover game cell.position) game

let check_state {board; _;} =
  if List.exists (fun cell -> cell.state = Uncovered && cell.has_mine) board.cells then
    (* Losing condition: any cell uncovered cell has a mine *)
    `lost
  else if List.filter (fun cell -> not cell.has_mine) board.cells |> List.for_all (fun cell -> cell.state = Uncovered) then
    (* Winning condition: all cells without mines have been uncovered *)
    `won
  else
    `normal

let num_mines_remaining {board; total_mines; _} =
  let n_flagged = List.filter (fun cell -> cell.state = Flagged) board.cells |> List.length
  in total_mines - n_flagged

let ensure_running_timer game =
  match game.start_time with
  | None -> {game with start_time = Some (Unix.time () |> int_of_float) }
  | Some _ -> game

let time_elapsed game =
  match game.start_time with
  | None -> 0
  | Some start_time -> (Unix.time () |> int_of_float) - start_time

let from_board board = 
  let total_mines = List.filter (fun cell -> cell.has_mine) board.cells |> List.length in
  {board; total_mines; start_time = None}