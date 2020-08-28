open GMain
open GdkKeysyms
open Types

let locale = GtkMain.Main.init ()

(* I _could_ make the board and cells each objects extended widgets...,
   including augmenting the cell data structure to also hold a reference to a
   gui cell, but seems a little dirty to me *)

let game_loop_gui game =
  let cell_width = 10 in
  let cell_height = 10 in
  let width = game.board.ncols * cell_width in
  let height = game.board.nrows * cell_height in
  let window = GWindow.window ~width ~height ~title:"Minesweeper in Ocaml" () in
  let grid = GPack.grid ~packing:window#add() in

  let game = ref game in
  let pos_to_gcell = List.map (fun cell ->
    let gcell = GButton.button ~label:" " () in
    grid#attach ~left:(cell.position.col * cell_width) ~top:(cell.position.row * cell_height) ~width:cell_width ~height:cell_height gcell#coerce; 
    let _ = gcell#event#connect#button_press ~callback:(fun ev ->
      match GdkEvent.Button.button ev with
      | 1 -> (* Left click *)
        (match GdkEvent.get_type ev with
        | `BUTTON_PRESS -> (* Single left click reveals current cell *)
          game := Game.uncover !game cell.position |> Game.tidy; true (* TODO what's the bool for?*)
        | `TWO_BUTTON_PRESS -> (* Double left click reveals non-flagged neighbors *)
          game := Game.uncover_neighbors !game cell.position |> Game.tidy; true
        | _ -> false
        )
      | 3 -> (* Right click flags the current cell *)
        game := Game.flag !game cell.position; true
      | _ -> false
    ) in
    (cell.position, gcell)
    ) !game.board.cells in

  let state = Game.check_state !game in
  let cell_display cell = match state with 
    | `won | `lost ->
        if cell.has_mine
          then "X"
          else Printf.sprintf "%d " (Board.n_mine_neighbors !game.board cell.position)
    | `normal ->
      match cell.state with
      | Uncovered ->
        if cell.has_mine
          then "X"
          else Printf.sprintf "%d" (Board.n_mine_neighbors !game.board cell.position)
      | Flagged -> ">"
      | Covered -> " "
  in

  (* Now update the cells *)
  let _ = window#event#connect#after_any ~callback:(fun _ -> 
    List.iter (fun (pos, gcell) ->
      match Board.get_cell !game.board pos with
      | Some cell -> 
        gcell#set_label (cell_display cell); ()
      | None -> failwith "No, that's impossible!"
    ) pos_to_gcell;
  ) in

  window#show ();

  match state with
  | `won | `lost -> Main.quit ()
  | `normal -> Main.main ()

let test_window () =
  let window = GWindow.window ~width:320 ~height:240
                              ~title:"Simple lablgtk program" () in
  let vbox = GPack.vbox ~packing:window#add () in
  let _id = window#connect#destroy ~callback:Main.quit in

  (* Menu bar *)
  let menubar = GMenu.menu_bar ~packing:vbox#pack () in
  let factory = new GMenu.factory menubar in
  let accel_group = factory#accel_group in
  let file_menu = factory#add_submenu "File" in

  (* File menu *)
  let factory = new GMenu.factory file_menu ~accel_group in
  let _menu_item = factory#add_item "Quit" ~key:_Q ~callback: Main.quit in

  (* Button *)
  let button = GButton.button ~label:"Push me!"
                              ~packing:vbox#add () in
  let _id = button#connect#clicked ~callback: (fun () -> prerr_endline "Ouch!") in

  (* Display the windows and enter Gtk+ main loop *)
  window#add_accel_group accel_group;
  window#show ();
  Main.main ()