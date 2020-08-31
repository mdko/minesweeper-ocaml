let status_to_string game = 
  let b = Buffer.create 16 in
  Buffer.add_string b (Printf.sprintf "Mines remaining: %d\n" (Game.num_mines_remaining game));
  Buffer.add_string b (Printf.sprintf "Time elapsed: %d\n" (Game.time_elapsed game));
  Buffer.contents b

let rec game_loop game =
  match Game.check_state game with
  | `won -> print_endline "You won!"; Board.board_to_string_numbered game.board |> print_endline
  | `lost -> print_endline "You lost :("; Board.board_to_string_numbered game.board |> print_endline
  | `normal ->
    status_to_string game |> print_endline;
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
        let game = Game.ensure_running_timer game in
        match action with
        | 'f' -> Game.flag game pos |> game_loop
        | 'u' -> Game.uncover game pos |> Game.tidy |> game_loop
        | 'n' -> Game.uncover_neighbors game pos |> Game.tidy |> game_loop
        | _ -> begin
          print_endline "Invalid action. Must be 'f' (for flag), 'u' (for uncover), or 'n' (for uncover neighbors).";
          game_loop game
        end