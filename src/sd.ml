open Sys
open Unix

let rec run_loop tasks =
  1

let rec start_loop () =
  Tasks.read_tab "testtab.json"
  |> List.filter (Tasks.should_run (localtime (gettimeofday ())))
  |> List.iter Tasks.run_task;
  Unix.sleep 1;
  start_loop ()

let shut_down status _ =
  exit status

let main =
  set_signal sigint (Signal_handle (shut_down 101));
  start_loop ()