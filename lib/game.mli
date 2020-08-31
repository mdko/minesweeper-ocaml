open Types

val flag : game -> position -> game
val uncover : game -> position -> game
val tidy : game -> game
val uncover_neighbors : game -> position -> game
val check_state : game -> [>`lost | `won | `normal]
val ensure_running_timer : game -> game
val num_mines_remaining : game -> int
val time_elapsed : game -> int