open Sys
open Unix

let await_next_run start_time =
  sleep (90 - start_time.tm_sec)


let rec run_loop () =
  let start_time = (localtime (time ())) in
  Tasks.read_tab "testtab.json"
  |> List.filter (Tasks.should_run start_time)
  |> List.iter Tasks.run_task;
  await_next_run start_time;
  run_loop ()

let start_up () =
  await_next_run (localtime (time ()));
  run_loop ()

let shut_down status _ =
  exit status

let main =
  set_signal sigint (Signal_handle (shut_down 0));
  start_up ()
