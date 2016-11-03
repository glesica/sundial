open Sys
open Unix

let rec set_timer base_time =
  let offset = if base_time.tm_sec < 30
    then 30
    else 90 in
  (* TODO: Log if we missed a timer. *)
  ignore (alarm (offset - base_time.tm_sec));
  sigsuspend [];
  set_timer (localtime (time ()))

let process_tasks _ =
  let start_time = (localtime (time ())) in
  Tasks.read_tab "testtab.json"
  |> List.filter (Tasks.should_run start_time)
  |> List.iter Tasks.run_task

let clean_up _ =
  (* TODO: Should probably log as they are forked and awaited. *)
  ignore (waitpid [WNOHANG] (0));
  ()

let shut_down status _ =
  exit status

let start_up () =
  set_signal sigalrm (Signal_handle process_tasks);
  set_signal sigchld (Signal_handle clean_up);
  set_signal sigint (Signal_handle (shut_down 0));
  set_timer (localtime (time ()))

let main =
  start_up ()
