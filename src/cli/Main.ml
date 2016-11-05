open Printf
open Sys
open Unix

let next_wake base_epoch =
  let base_time = localtime base_epoch in
  let offset = float_of_int (90 - base_time.tm_sec) in
  base_epoch +. offset

let rec process_loop wake_epoch tab =
  let start_epoch = time () in
  if wake_epoch -. start_epoch < 1.0 then
    let start_time = localtime start_epoch in
    tab
    |> List.filter (Tasks.should_run start_time)
    |> List.iter Tasks.run_task;
    process_loop (next_wake start_epoch) tab
  else
    sleep (int_of_float (wake_epoch -. start_epoch));
    process_loop wake_epoch tab
  
let clean_up pid =
  try while fst (waitpid [WNOHANG] (-1)) > 0 do () done
  with Unix_error (ECHILD, _, _) -> ()

let shut_down status _ =
  exit status

let start_up () =
  set_signal sigchld (Signal_handle clean_up);
  set_signal sigint (Signal_handle (shut_down 0));
  let tab_path = Tabs.get_first_tab_path () in
  let tab = Tasks.read_tab tab_path in
  process_loop (next_wake (time ())) tab

let main =
  start_up ()
