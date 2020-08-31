open GMain
open Types

let _locale = GtkMain.Main.init ()

(* I _could_ make the board and cells each objects extended widgets...,
   including augmenting the cell data structure to also hold a reference to a
   gui cell, but seems a little dirty to me *)

let _cell_display game cell =
  match Game.check_state game with 
  | `won | `lost ->
      if cell.has_mine then
        match cell.state with
        | Flagged -> ">"
        | _ -> "X"
      else begin
        match cell.state with
        | Flagged -> "%" (* TODO e.g. bomb with red cross through it *)
        | _ -> Printf.sprintf "%d " (Board.n_mine_neighbors game.board cell.position)
      end
  | `normal ->
    match cell.state with
    | Uncovered ->
      if cell.has_mine
        then "X"
        else Printf.sprintf "%d" (Board.n_mine_neighbors game.board cell.position)
    | Flagged -> ">"
    | Covered -> " "

let get_img name =
  let pb = GdkPixbuf.from_file_at_size ("assets/" ^ name ^ ".png") ~width:30 ~height:30 in
  GMisc.image ~pixbuf:pb ()

let neighbor_img n = string_of_int n |> get_img

let cell_display_image game cell =
  match Game.check_state game with 
  | `won | `lost ->
      if cell.has_mine then
        match cell.state with
        | Flagged -> get_img "flag"
        | _ -> get_img "mine"
      else begin
        match cell.state with
        | Flagged -> get_img "cross_mine"
        | _ -> neighbor_img (Board.n_mine_neighbors game.board cell.position)
      end
  | `normal ->
    match cell.state with
    | Uncovered ->
      if cell.has_mine
        then get_img "mine"
        else neighbor_img (Board.n_mine_neighbors game.board cell.position)
    | Flagged -> get_img "flag"
    | Covered -> get_img "covered"

let game_loop game =
  let cell_width = 10 in
  let cell_height = 10 in
  let status_height = 10 in
  let width = game.board.ncols * cell_width in
  let height = game.board.nrows * cell_height + status_height in
  let window = GWindow.window ~width ~height ~title:"Minesweeper in Ocaml" () in
  let content = GPack.vbox ~packing:window#add() in
  let status = GPack.hbox ~packing:content#add() ~height:status_height in
  let mines_remaining = GText.buffer ~text:(string_of_int game.total_mines) () in
  let time_elapsed = GText.buffer ~text:"0" () in
  let _mines_remaining_view = GText.view ~buffer:mines_remaining ~packing:status#add() in
  let _time_elapsed_view = GText.view ~buffer:time_elapsed ~packing:status#add() in
  let grid = GPack.grid ~packing:content#add() in

  let game = ref game in
  (* Register the cell clicks *)
  let pos_to_gcell = List.map (fun cell ->
    (* NOTE: because of peculiarites in the API, you cannot set the label argument
       when creating the button, or it won't show the image. *)
    let gcell = GButton.button () in
    gcell#set_image (cell_display_image !game cell)#coerce;
    grid#attach ~left:(cell.position.col * cell_width) ~top:(cell.position.row * cell_height) ~width:cell_width ~height:cell_height gcell#coerce; 
    let _ = gcell#event#connect#button_press ~callback:(fun ev ->
      match GdkEvent.Button.button ev with
      | 1 -> (* Left click *)
        (match GdkEvent.get_type ev with
        | `BUTTON_PRESS -> (* Single left click reveals current cell *)
          game := Game.uncover !game cell.position |> Game.ensure_running_timer |> Game.tidy; true (* TODO what's the bool for?*)
        | `TWO_BUTTON_PRESS -> (* Double left click reveals non-flagged neighbors *)
          game := Game.uncover_neighbors !game cell.position |> Game.ensure_running_timer |> Game.tidy; true
        | _ -> false
        )
      | 3 -> (* Right click flags the current cell *)
        game := Game.flag !game cell.position |> Game.ensure_running_timer; true
      | _ -> false
    ) in
    (cell.position, gcell)
    ) !game.board.cells in

  (* Attach visual updates to an event so they are updated in the Main event loop *)
  let _ = window#event#connect#after_any ~callback:(fun _ -> 
    let state = Game.check_state !game in
    (* Update cells display *)
    List.iter (fun (pos, gcell) ->
      match Board.get_cell !game.board pos with
      | Some cell -> 
        (* gcell#set_label (cell_display !game cell); () *)
        gcell#set_image (cell_display_image !game cell)#coerce;
      | None -> failwith "No, that's impossible!"
    ) pos_to_gcell;
    (* Update mines remaining display *)
    mines_remaining#set_text (Game.num_mines_remaining !game |> string_of_int);
    match state with
    | `won | `lost -> () (*Main.quit ()*) (* TODO display something nice *)
    | _ -> ()
  ) in

  (* And update the elapsed time bar every second *)
  let _ = GMain.Timeout.add ~ms:1000 ~callback:(fun _ ->
    let state = Game.check_state !game in
    (match state with
    | `normal -> time_elapsed#set_text (Game.time_elapsed !game |> string_of_int)
    | _ -> ()
    );
    true
  ) in

  window#show ();
  Main.main ()