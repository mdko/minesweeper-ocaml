open Types

val board_to_string : ?f:(cell -> string) -> board -> string
val board_to_string_numbered : board -> string
val board_to_string_positions : board -> string

val new_board_random : int -> int -> int -> board
val new_board_solveable_no_guesses : int -> int -> int -> board
val array_to_board : int -> int -> int list -> board

val get_cell : board -> position -> cell option
val set_cell : board -> cell -> board
val is_bad_pos : board -> position -> bool
val get_neighbors : board -> position -> cell list
val n_mine_neighbors : board -> cell -> int