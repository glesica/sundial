open Unix
open Sys

let rec start_loop () =
  Sundial.read_tab "testtab.json"
  |> List.iter Sundial.run_task;
  print_string (Sundial.current_time ());
  Unix.sleep 1;
  start_loop ()

let shut_down status _ =
  exit status

let main =
  set_signal sigint (Signal_handle (shut_down 101));
  start_loop ()